<CsoundSynthesizer>

<CsOptions>

-odac
-Ma

</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 1
0dbfs = 1

opcode oGet, i, S

SName xin

SControl sprintf "%f/%d/%s", p1, p4, SName
iValue chnget SControl

xout iValue

endop

opcode oMaqam, i, S

SMaqam xin

SFT strcat "maqam/", SMaqam

iFT chnget SFT

xout iFT

endop

opcode oEnvelope, ak, iiiii

iEnvelope, iAttack, iEnvelopeAttack, iDecay, iSustain xin

tigoto Envelope

kEnvelope init 0

Envelope:

if iAttack == 0 || iDecay == 0 igoto static
if iAttack == 0 || iDecay == 0 kgoto static

aEnvelope subinstr "envelope", kEnvelope, 1/iAttack, iEnvelope * iEnvelopeAttack, 1/iDecay, iEnvelope * iSustain

kEnvelope = k ( aEnvelope )

igoto out
kgoto out

static:

aEnvelope init iEnvelope
kEnvelope init iEnvelope

out:

xout aEnvelope, kEnvelope

endop

opcode oWave, i, ii

iWave, iFrequency xin

if iWave == -1 then

iWaveFT = -1

else

iWaveFT vco2ift iFrequency, iWave

endif

xout iWaveFT

endop

giNextFT vco2init 31, 100

massign 0, 0

instr 13, oscilla

tigoto control

SInstrument strget p4
iInstrument nstrnum SInstrument
iInstrument += frac ( p1 )

iMaqam = 0

prints "#oscilla Initializing %s at %f\n", SInstrument, iInstrument

iNote = 0

igoto end

control:

iStatus = p4
iData1 = p5
iData2 = p6

if iStatus == 192 then ; Program Change

SMaqam strget iData1
iMaqam oMaqam SMaqam

elseif iStatus == 176 then ; Control Change

iStatus = p5
SControlName strget p6
SControl sprintf "%f/%d/%s", iInstrument, iStatus, SControlName

chnset p7, SControl

prints "#oscilla #parameter %s = %d\n", SControl, p7

p4 = 0
p5 = 0
p6 = 0
p7 = 0

elseif iStatus == 128 then ; Note Off

iNote += -1

if iNote == 0 then

iFrequency cpstuni iData1, iMaqam

schedule iInstrument, 0, -1, iStatus, iData1, iData2, iFrequency

endif

elseif iStatus == 144 then ; Note On

iFrequency cpstuni iData1, iMaqam

schedule iInstrument, 0, -1, iStatus, iData1, iData2, iFrequency

iNote += 1

endif

end:

endin

instr maqam

SMaqam strget p4

iFT ftgen 0, 0, 64, -2, 12, 2, cpsmidinn ( 60 ), 60, p5, 0, p6, 0, p7, p8, 0, p9, 0, p10, 0, p11

SFT strcat "maqam/", SMaqam

chnset iFT, SFT

endin

instr oscillator

iAttack oGet "attack"
iDecay oGet "decay"

iAmplitude init p6 / 127
iAmplitudeSustain oGet "amplitudeSustain"

aAmplitude, kAmplitude oEnvelope iAmplitude, iAttack, 1, iDecay, iAmplitudeSustain

iFrequencyDetune oGet "frequencyDetune"
iFrequency = p7 * cent ( iFrequencyDetune )
iFrequencyAttack oGet "frequencyAttack"

aFrequency, kFrequency oEnvelope iFrequency, iAttack, iFrequencyAttack, iDecay, 1

AM:

iAMWave oGet "AMWave"
iAMWaveFT oWave iAMWave, iFrequency
iAMFactor oGet "AMFactor"

if iAMFactor == 0 kgoto FM

aAM poscil aAmplitude, aFrequency * cent ( iAMFactor * 1200 ), iAMWaveFT, -1

aAmplitude = aAM

FM:

iFMWave oGet "FMWave"
iFMWaveFT oWave iFMWave, iFrequency
iFMFactor oGet "FMFactor"

if iFMFactor == 0 kgoto oscillate

aFM poscil aFrequency, aFrequency * cent ( iFMFactor * 1200 ), iFMWaveFT, -1

aFrequency = aFM

oscillate:

iWave oGet "wave"
iWaveFT oWave iWave, iFrequency

print iFrequency
print iAmplitude

aNote poscil aAmplitude, aFrequency, iWaveFT, -1

chnmix aNote, "note"

endin

instr noise

iAttack oGet "attack"
iDecay oGet "decay"

iAmplitude init p6 / 127
iAmplitudeSustain oGet "amplitudeSustain"

aAmplitude, kAmplitude oEnvelope iAmplitude, iAttack, 1, iDecay, iAmplitudeSustain

aNoise rand aAmplitude

iFrequency = p7
iFrequencyAttack oGet "frequencyAttack"

aFrequency, kFrequency oEnvelope iFrequency, iAttack, iFrequencyAttack, iDecay, 1

aBandWidth init 1000

aFiltered areson aNoise, aFrequency, aBandWidth

aWave poscil aAmplitude, aFrequency

aNote balance aFiltered, aWave

chnmix aNote, "note"

endin

instr envelope

aEnvelope linsegr p4, p5, p6, p7, p8, 1, 0

out aEnvelope

endin

instr reverb

aNote chnget "note"

iTime oGet "time"
iAmplitude oGet "amplitude"

aReverb reverb aNote, iTime, -1

chnmix aReverb / iAmplitude, "note"

endin

instr out

aNote chnget "note"

aNote clip aNote, 1, 1

kReleased lastcycle

if kReleased == 1 then

p3 += 1

kNote = k ( aNote )

if kNote == 0 then

turnoff

endif

endif

out aNote

chnclear "note"

endin

instr keyboard

kCharacter, kDown sense

endin

</CsInstruments>

<CsScore bin="node ./">
</CsScore>

</CsoundSynthesizer>
