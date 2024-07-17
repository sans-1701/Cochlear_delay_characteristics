% Parameters
b0 = 0.795;
b1 = 0.865;
data = '1111111111111111111';
fs = 500;  % Sample rate of the original signal (adjust as needed)
Nbit = 16;   % Bit rate per second for data embedding (adjust as needed)
frameLength = fs / Nbit;
overlap = frameLength / 2;

% Generate a sample signal (replace this with your actual signal)
F = 100;
Ts = 1/fs;
t = 0:Ts:5;  % Time vector
originalSignal = sin(2*pi*F*t);  % Example input signal

% Step 1: Design IIR all-pass filters
H0_num = [1, -b0];
H1_num = [1, -b1];

% Step 2: Filter the original signal
w0 = filter(H0_num, 1, originalSignal);
w1 = filter(H1_num, 1, originalSignal);

% Step 3: Set embedded data
embeddedData = arrayfun(@(bit) str2double(bit), data);

% Step 4: Merge intermediate signals with watermarked signal
watermarkedSignal = zeros(size(originalSignal));
for k = 1:length(embeddedData)
    startIdx = (k - 1) * frameLength + 1;
    endIdx = min(k * frameLength, length(originalSignal));  % Ensure not to exceed array dimensions
    
    if embeddedData(k) == 0
        watermarkedSignal(startIdx:endIdx) = w0(startIdx:endIdx);
    else
        watermarkedSignal(startIdx:endIdx) = w1(startIdx:endIdx);
    end
end

% Step 5: Apply weighting ramped cosine function to handle discontinuity
rampLength = 100;  % Adjust as needed
ramp = linspace(0, 1, rampLength);
rampFunction = [ramp, ones(1, frameLength - 2 * rampLength), fliplr(ramp)];

% Apply the ramp function to each frame of watermarkedSignal
for k = 1:length(embeddedData)
    startIdx = (k - 1) * frameLength + 1;
    endIdx = min(k * frameLength, length(originalSignal));  % Ensure not to exceed array dimensions
    
    watermarkedSignal(startIdx:endIdx) = watermarkedSignal(startIdx:endIdx) .* rampFunction(1:endIdx - startIdx + 1);
end

% Display the signals
time = (0:length(originalSignal)-1) / fs;

figure;
subplot(2, 1, 1);
plot(time, originalSignal, 'b', 'LineWidth', 1.5);
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(time, watermarkedSignal, 'r', 'LineWidth', 1.5);
title('Watermarked Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Adjust the figure as needed

% DATA DETECTION 
% Assuming x(n) and y(n) are available
% Assuming watermarkedSignal and originalSignal are the watermarked and original signals, respectively

% Step 2: Decompose signals into overlapped segments using the same window function
window = hann(frameLength);  % Use the same window as in the data embedding
overlap = floor(frameLength / 2);  % Ensure overlap is an integer

% Ensure originalSignal and watermarkedSignal have the same length
minLength = min(length(originalSignal), length(watermarkedSignal));
originalSignal = originalSignal(1:minLength);
watermarkedSignal = watermarkedSignal(1:minLength);

% Segment the signals
numSegments = floor((minLength - overlap) / (frameLength - overlap));
segmentsOriginal = zeros(round(frameLength), numSegments);
segmentsWatermarked = zeros(round(frameLength), numSegments);

for i = 1:numSegments
    startIdx = (i - 1) * (frameLength - overlap) + 1;
    endIdx = startIdx + frameLength - 1;

    segmentsOriginal(:, i) = originalSignal(startIdx:endIdx) .* window.';
    segmentsWatermarked(:, i) = watermarkedSignal(startIdx:endIdx) .* window.';


end

% Continue with the rest of the code...

% Step 3: Calculate the phase difference φ(ω) in each segment
fftOriginal = fft(segmentsOriginal .* window);
fftWatermarked = fft(segmentsWatermarked .* window);

phaseDifference = angle(fftWatermarked) - angle(fftOriginal);

% Step 4: Calculate summed phase differences ∆Φ0 and ∆Φ1
H0_freqz = angle(freqz([1, -b0], 1, length(fftOriginal)));
H1_freqz = angle(freqz([1, -b1], 1, length(fftOriginal)));

deltaPhi0 = sum(phaseDifference - H0_freqz.');
deltaPhi1 = sum(phaseDifference - H1_freqz.');


% Step 5: Detect the embedded data sˆ(k)
detectedData = zeros(1, length(deltaPhi0));
detectedData(deltaPhi0 < deltaPhi1) = 0;
detectedData(deltaPhi0 >= deltaPhi1) = 1;

% Display the detected data
disp('Detected Data:');
disp(detectedData);
