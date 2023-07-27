<CsoundSynthesizer>

<CsOptions>

-Lstdin
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

print p1
print p4
SControl sprintf "%f/%d/%s", p1, p4, SName
iValue chnget SControl

prints "%s: %f\n", SControl, iValue

xout iValue

endop

opcode oMaqam, i, S

SMaqam xin

SFT strcat "maqam/", SMaqam

iFT chnget SFT

xout iFT

endop

opcode oEnvelope, ak, Siiiiio

SName, iTarget, iAttack, iEnvelopeAttack, iDecay, iSustain, iInitialize xin

SEnvelope sprintf "%f/%s", p1, SName
iEnvelope chnget SEnvelope

; prints "%s: %f\n", SName, iEnvelope

if iEnvelope == 0 && iInitialize != 0 then

iEnvelope = iTarget

endif

if iAttack == 0 || iDecay == 0 igoto static
if iAttack == 0 || iDecay == 0 kgoto static

aEnvelope linseg iEnvelope, 1/iAttack, iTarget * iEnvelopeAttack, 1/iDecay, iTarget * iSustain

chnset k ( aEnvelope ), SEnvelope

igoto out
kgoto out

static:

aEnvelope init iTarget
kEnvelope init iTarget

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

opcode oModulate, a, Saai

SModulator, aParameter, aFrequency, iFrequency xin

iModulator oGet SModulator

if iModulator <= 0 kgoto static

SWave strcat SModulator, "/wave"
iWave oGet SWave
iWaveFT oWave iWave, iFrequency

SDetune strcat SModulator, "/detune"
iDetune oGet SDetune

aModulator poscil aParameter, aFrequency * cent ( iDetune * 100 ), iWaveFT, -1

igoto out
kgoto out

static:

aModulator = aParameter

out:

xout aModulator

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

print iAttack

iAmplitude init p6 / 127
iAmplitudeSustain oGet "amplitudeSustain"

aAmplitude, kAmplitude oEnvelope "amplitude", iAmplitude, iAttack, 1, iDecay, iAmplitudeSustain

iFrequencyDetune oGet "frequencyDetune"
iFrequency = p7 * cent ( iFrequencyDetune * 100 )
iFrequencyAttack oGet "frequencyAttack"
iFrequencyAttack = cent ( iFrequencyAttack * 100 )

aFrequency, kFrequency oEnvelope "frequency", iFrequency, iAttack, iFrequencyAttack, iDecay, 1, 1

aAmplitude oModulate "AM", aAmplitude, aFrequency, iFrequency

aFrequency oModulate "FM", aFrequency, aFrequency, iFrequency

iWave oGet "wave"
iWaveFT oWave iWave, iFrequency

aNote poscil aAmplitude, aFrequency, iWaveFT, -1

chnmix aNote, "note"

endin

instr noise

iAttack oGet "attack"
iDecay oGet "decay"

iAmplitude init p6 / 127
iAmplitudeSustain oGet "amplitudeSustain"

aAmplitude, kAmplitude oEnvelope "amplitude", iAmplitude, iAttack, 1, iDecay, iAmplitudeSustain

aNoise rand aAmplitude

iFrequency = p7
iFrequencyAttack oGet "frequencyAttack"

aFrequency, kFrequency oEnvelope "frequency", iFrequency, iAttack, iFrequencyAttack, iDecay, 1

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

schedule "lastCycle", 0, p3
schedule "monitorRelease", 0, -1

p3 += 36000

aNote chnget "note"

aNote clip aNote, 1, 1

out aNote

chnset k ( aNote ), "kNote"

chnclear "note"

endin

gkReleased init -1

instr lastCycle

gkReleased lastcycle

endin

instr monitorRelease

if gkReleased == 1 then

kNote chnget "kNote"

if kNote <= 0 then

schedulek "exit", 0, 0, 0

endif

endif

endin

instr exit

exitnow p4

endin

</CsInstruments>

<CsScore bin="node ./">
</CsScore>

</CsoundSynthesizer>
