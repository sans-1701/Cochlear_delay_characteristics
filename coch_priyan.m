% Audio Watermarking Based on Cochlear Delay

% Load the audio signal
[x, fs] = audioread('input_audio.wav');

% Watermark signal (binary message)
watermark = randi([0, 1], 1, length(x));

% Parameters
spreadFactor = 100; % Spread factor for spreading the watermark
alpha = 0.01; % Scaling factor for embedding

% Cochlear delay simulation
delayedSignal = zeros(size(x));
for f = 20:20:20000
    % Apply delay based on cochlear frequency
    delay = round((1 + sin(2 * pi * f * (1:length(x))/fs)) * spreadFactor);
    delayedSignal = delayedSignal + alpha * circshift(x, delay);
end

% Embed watermark using spread spectrum
watermarkedSignal = delayedSignal + alpha * spreadFactor * watermark;

% Save watermarked audio
audiowrite('watermarked_audio.wav', watermarkedSignal, fs);

% To extract the watermark
extractedWatermark = round((watermarkedSignal - delayedSignal) / (alpha * spreadFactor));

% Evaluation
bitErrorRate = sum(abs(watermark - extractedWatermark)) / length(watermark);
disp(['Bit Error Rate: ', num2str(bitErrorRate)]);

% Plot original, watermarked, and extracted signals
figure;
subplot(3, 1, 1), plot(x), title('Original Signal');
subplot(3, 1, 2), plot(watermarkedSignal), title('Watermarked Signal');
subplot(3, 1, 3), plot(extractedWatermark), title('Extracted Watermark');

