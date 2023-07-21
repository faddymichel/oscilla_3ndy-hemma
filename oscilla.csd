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

print iData1
print iFrequency

schedule iInstrument, 0, -1, iStatus, iData1, iData2, iFrequency

iNote += 1

endif

end:

endin

instr maqam

SMaqam strget p4

iFT ftgen 0, 0, 64, -2, 12, 2, cpsmidinn ( 60 ), 60, p5, 0, p6, 0, p7, p8, 0, p9, 0, p10, 0, p11

print iFT

SFT strcat "maqam/", SMaqam

chnset iFT, SFT

endin

instr oscillator

iAttack oGet "attack"
iDecay oGet "decay"

iAmplitude init p6 / 127
iAmplitudeSustain oGet "amplitudeSustain"

tigoto amplitudeEnvelope

kAmplitude init 0

amplitudeEnvelope:

aAmplitude subinstr "envelope", kAmplitude, 1/iAttack, iAmplitude, 1/iDecay, iAmplitude * iAmplitudeSustain

kAmplitude = k ( aAmplitude )

tigoto frequencyEnvelope

iFrequencyInitial = 0
kFrequency init 0

frequencyEnvelope:

iFrequencyDetune oGet "frequencyDetune"

iFrequency = p7 * cent ( iFrequencyDetune )
iFrequencyAttack oGet "frequencyAttack"

if iFrequencyInitial == 0 then

kFrequency init iFrequency
iFrequencyInitial = iFrequency

endif

aFrequency subinstr "envelope", kFrequency, 1/iAttack, iFrequency * cent ( iFrequencyAttack ), 1/iDecay, iFrequency

kFrequency = k ( aFrequency )

iWave oGet "wave"

if iWave == -1 then

iWaveFT = -1

else

iWaveFT vco2ift iFrequency, iWave

endif

aNote poscil aAmplitude, aFrequency, iWaveFT, -1

chnmix aNote, "note"

endin

/*
instr noise

aNoise noise 1, kFilterEnvelope

out aNoise * aAmplitudeEnvelope

endin
*/

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
