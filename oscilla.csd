<CsoundSynthesizer>

<CsOptions>

-Lstdin
-odac
-Ma

</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

opcode oGet, i, So

SName, iDefault xin

SControl sprintf "%f/%d/%s", p1, p4, SName
iValue chnget SControl

if iValue == 0 then

iValue = iDefault

endif

xout iValue

endop

opcode oMix, 0, aao

aNoteLeft, aNoteRight, iClear xin

if p8 == 0 then

SChannel = "note"

else

SChannel sprintf "channel/%d", p8

endif

SChannelLeft strcat SChannel, "/left"
SChannelRight strcat SChannel, "/right"

if k ( iClear ) == 1 then

chnclear SChannelLeft
chnclear SChannelRight

endif

chnmix aNoteLeft, SChannelLeft
chnmix aNoteRight, SChannelRight

endop

opcode oChannel, aa, 0

SChannel sprintf "channel/%d", p8
SChannelLeft strcat SChannel, "/left"
SChannelRight strcat SChannel, "/right"

aNoteLeft chnget SChannelLeft
aNoteRight chnget SChannelRight

xout aNoteLeft, aNoteRight

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

opcode oAmplitude, aki, 0

iAttack oGet "attack"
iDecay oGet "decay"

iAmplitude init p6 / 127
iAmplitudeAttack oGet "amplitudeAttack", 1
iAmplitudeSustain oGet "amplitudeSustain"

aAmplitude, kAmplitude oEnvelope "amplitude", iAmplitude, iAttack, iAmplitudeAttack, iDecay, iAmplitudeSustain

xout aAmplitude, kAmplitude, iAmplitude

endop

opcode oFrequency, aki, 0

iFrequencyDetune oGet "frequencyDetune"
iUnisonDetune oGet "unisonDetune"

iFrequency = p7 * cent ( iFrequencyDetune * 100 ) * cent ( p9 * iUnisonDetune * 100 )

iFrequencyAttack oGet "frequencyAttack"
iFrequencyAttack = cent ( iFrequencyAttack * 100 )

iFrequencySustain oGet "frequencySustain"
iFrequencySustain = cent ( iFrequencySustain * 100 )

iAttack oGet "attack"
iDecay oGet "decay"

aFrequency, kFrequency oEnvelope "frequency", iFrequency, iAttack, iFrequencyAttack, iDecay, iFrequencySustain, 1

xout aFrequency, kFrequency, iFrequency

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

opcode oLowpass, a, aa

aNote, aFrequency xin

tigoto lowpass

iSkip = 0

lowpass:

iLowpass oGet "lowpass"
iLowpassDetune oGet "lowpass/detune"
iLowpassLayers oGet "lowpass/layers", 1

if iLowpass <= 0 kgoto highpass

aNote tonex aNote, aFrequency * cent ( iLowpassDetune * 100 ), iLowpassLayers, iSkip

highpass:

iHighpass oGet "highpass"
iHighpassDetune oGet "highpass/detune"
iHighpassLayers oGet "highpass/layers", 1

if iHighpass <= 0 kgoto out

aNote atonex aNote, aFrequency * cent ( iHighpassDetune * 100 ), iHighpassLayers, iSkip

out:

iSkip += -1

aFiltered = aNote

xout aNote

endop

giNextFT vco2init 31, 100

massign 0, 0

instr 13, oscilla

tigoto control

SInstrument strget p4
iInstrument nstrnum SInstrument
iInstrument += frac ( p1 )

iChannel = p5
iPartial = p6

if iChannel >= 1 then

iChannelInstrument nstrnum "channel"
iChannelInstrument += frac ( iChannel / 1000000 )

schedule iChannelInstrument, 0, -1, iChannel

endif

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

prints "#oscilla #tuning #maqam %d %s\n", iMaqam, SMaqam

elseif iStatus == 176 then ; Control Change

iStatus = p5
SControlName strget p6
SControl sprintf "%f/%d/%s", iInstrument, iStatus, SControlName

chnset p7, SControl

prints "#oscilla #parameter %s %d\n", SControl, p7

p4 = 0
p5 = 0
p6 = 0
p7 = 0

elseif iStatus == 128 then ; Note Off

iNote += -1

if iNote == 0 then

iFrequency cpstuni iData1, iMaqam

prints "#oscilla #noteOff %d %d %d %d %d\n", iStatus, iData1, iData2, iFrequency, iChannel

schedule iInstrument, 0, -1, iStatus, iData1, iData2, iFrequency, iChannel, iPartial

endif

elseif iStatus == 144 then ; Note On

prints "#oscilla %s %f\n", SInstrument, iInstrument
iFrequency cpstuni iData1, iMaqam

prints "#oscilla #noteOn %d %d %d %d %d\n", iStatus, iData1, iData2, iFrequency, iChannel

schedule iInstrument, 0, -1, iStatus, iData1, iData2, iFrequency, iChannel, iPartial

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

#define p #iP [] fillarray p4, p5, p6, p7, p8, p9#

instr oscillator

$p

aAmplitude, kAmplitude, iAmplitude oAmplitude

aFrequency, kFrequency, iFrequency oFrequency

aAmplitude oModulate "AM", aAmplitude, aFrequency, iFrequency

aFrequency oModulate "FM", aFrequency, aFrequency, iFrequency

iWave oGet "wave"
iWaveFT oWave iWave, iFrequency

aNote poscil aAmplitude, aFrequency, iWaveFT, -1

oMix aNote, aNote

endin

instr noise

$p

aAmplitude, kAmplitude, iAmplitude oAmplitude

aNoise rand aAmplitude

oMix aNoise, aNoise

endin

instr filter

tigoto filter

iSkip = 0

filter:

$p

aNoteLeft, aNoteRight oChannel

aFrequency, kFrequency, iFrequency oFrequency

iAttack oGet "attack"
iDecay oGet "decay"

lowpass:

iLowpass oGet "lowpass"
iLowpassDetune oGet "lowpass/detune"
iLowpassLayers oGet "lowpass/layers", 1

if iLowpass <= 0 kgoto highpass

aNoteLeft tonex aNoteLeft, aFrequency * cent ( iLowpassDetune * 100 ), iLowpassLayers, iSkip
aNoteRight tonex aNoteRight, aFrequency * cent ( iLowpassDetune * 100 ), iLowpassLayers, iSkip

highpass:

iHighpass oGet "highpass"
iHighpassDetune oGet "highpass/detune"
iHighpassLayers oGet "highpass/layers", 1

if iHighpass <= 0 kgoto out

aNoteLeft atonex aNoteLeft, aFrequency * cent ( iHighpassDetune * 100 ), iHighpassLayers, iSkip
aNoteRight atonex aNoteRight, aFrequency * cent ( iHighpassDetune * 100 ), iHighpassLayers, iSkip

out:

iSkip += -1

oMix aNoteLeft, aNoteRight, 1

endin

instr reverb

tigoto reverb

iSkip = 0

reverb:

$p

aNoteLeft, aNoteRight oChannel

iAttack oGet "attack"
iDecay oGet "decay"

iRoomSize oGet "roomSize"
iRoomSizeAttack oGet "roomSizeAttack"
iRoomSizeSustain oGet "roomSizeSustain"

aRoomSize, kRoomSize oEnvelope "roomSize", iRoomSize, iAttack, iRoomSizeAttack, iDecay, iRoomSizeSustain

kHFDamp init .75

denorm aNoteLeft, aNoteRight

aNoteLeft, aNoteRight freeverb aNoteLeft, aNoteRight, kRoomSize, kHFDamp, sr, iSkip

iSkip += -1

aAmplitude, kAmplitude, iAmplitude oAmplitude

aNoteLeft = aNoteLeft * aAmplitude 
aNoteRight = aNoteRight * aAmplitude

oMix aNoteLeft, aNoteRight; , 1

endin

instr channel

SChannel sprintf "channel/%d", p4
SChannelLeft strcat SChannel, "/left"
SChannelRight strcat SChannel, "/right"

aNoteLeft chnget SChannelLeft
aNoteRight chnget SChannelRight

chnmix aNoteLeft, "note/left"
chnmix aNoteRight, "note/right"

chnclear SChannelLeft
chnclear SChannelRight

endin

instr out

schedule "lastCycle", 0, p3
schedule "monitorRelease", 0, -1

p3 += 36000

aNoteLeft chnget "note/left"
aNoteRight chnget "note/right"

aNoteLeft clip aNoteLeft, 1, 1
aNoteRight clip aNoteRight, 1, 1

outs aNoteLeft, aNoteRight

chnset k ( aNoteLeft ), "kNote"

chnclear "note/left"
chnclear "note/right"

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
