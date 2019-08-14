--LSynth by RamiLego4Game & LIKO-12's Organization
--The portable fantasy audio chip made for LIKO-12 which could be used in any LÖVE project.

--[[
Required love modules:
love.thread

Optional love modules:
love.system (Used to know if running on mobile)

Love modules used by threads:
love.timer (Used to calculate the sleeping time)
love.sound (Used for creating sounddatas)
love.audio (Used for playing the generated sounddatas)
]]

local path = (...) --The library require path.
local dir = string.gsub(path, "%.", "/") --The directory of the library.

local LSynth = {}

--==Private Fields==--
--Those fields should not be modified by external code.

LSynth.initialized = false --Has the LSynth chip been initialized ?
LSynth.isMobile = false --Is the chip running on a mobile device ?

LSynth.channels = 4 --Default channels count.
LSynth.sampleRate = 44100 --Default sample rate (samples per second), 22050 on mobile (if detected).
LSynth.bufferLength = 1/60 --Default buffer length (in seconds).
LSynth.piecesCount = 4 --Default count of buffer pieces (affects responsivity).

LSynth.thread = nil --The LSynth chip thread.
LSynth.outChannel = nil --The channel which sends data into the LSynth thread.

--==Public Methods==--

--[[ Initialize the LSynth chip.
Call before any other method !

Arguments:
- channels (number/nil): (unsigned int) The number of channels to have.
- sampleRate (number/nil): (unsigned int) The sample rate to operate on, by default it's 44100 on PC, and 22050 on mobile.
- bufferLength (number/nil): (unsigned float) The length of the buffer in seconds, by defaults it's 1/60.
- piecesCount (number/nil): (unsigned int) The number of pieces to divide the buffer into, affects responsivity, by default it's 4.
]]
function LSynth:initialize(channels, sampleRate, bufferLength, piecesCount)
	if self.initialized then error("Already initialized!") end

	--Check if running on mobile, if love.system is available.
	self.isMobile = love.system and ((love.system.getOS() == "Android") or (love.system.getOS() == "iOS"))

	--Lower the sample rate if running on mobile.
	if self.isMobile then LSynth.sampleRate = 22050 end

	--Override the channels count.
	if channels then self.channels = channels end
	--Override the sample rate.
	if sampleRate then self.sampleRate = sampleRate end
	--Override the buffer length.
	if bufferLength then self.bufferLength = bufferLength end
	--Override the pieces count.
	if piecesCount then self.piecesCount = piecesCount end
	
	--Create the communication channel
	self.outChannel = love.thread.newChannel()

	--Load the thread
	self.thread = love.thread.newThread(dir.."/thread.lua")
	--Start the thread
	self.thread:start(self.channels ,self.sampleRate, self.bufferLength, self.piecesCount, self.outChannel)

	self.initialized = true
end

--== Hooks ==--

--love.update
function LSynth:update(dt)
	if not self.initialized then error("The chip has not been initialized yet!") end
end

return LSynth