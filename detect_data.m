function detected_watermark = detect_data(original_signal, watermarked_signal, watermark_length)
    % Data detection process
    
    % Parameters
    window_size = 512; % Adjust based on your requirements
    overlap = 0.5; % Adjust based on your requirements
    b0 = 0.795; % Coefficient for H0(z)
    b1 = 0.865; % Coefficient for H1(z)
    
    % Step 2: Decompose signals into overlapped segments
    segments_x = buffer(original_signal, window_size, window_size * overlap, 'nodelay');
    segments_y = buffer(watermarked_signal, window_size, window_size * overlap, 'nodelay');
    
    % Step 3: Calculate phase difference in each segment
    phase_diff = angle(fft(segments_x)) - angle(fft(segments_y));
    
    % Step 4: Calculate summed phase differences for H0(z) and H1(z)
    phase_diff_H0 = angle(fft(allpass(b0, window_size))) * size(phase_diff, 1);
    phase_diff_H1 = angle(fft(allpass(b1, window_size))) * size(phase_diff, 1);
    
    delta_phi_H0 = sum(phase_diff, 1) - phase_diff_H0;
    delta_phi_H1 = sum(phase_diff, 1) - phase_diff_H1;
    
    % Step 5: Detect embedded data
    detected_watermark = (delta_phi_H0 < delta_phi_H1);
    detected_watermark = detected_watermark(1:watermark_length); % Extract the relevant part
    
    disp(['Detected Watermark: ' num2str(detected_watermark)]);
end

function Hd = allpass(b, window_size)
    % Design an all-pass filter using given coefficient b
    
    % Coefficients for the all-pass filter
    a = 1;
    
    % Design the filter
    Hd = dfilt.df2(a, b);
    
    % Convert to filter object with specified order (window size)
    Hd = dfilt.dffir(Hd, 'Numerator', Hd.Numerator, 'Denominator', Hd.Denominator, 'FilterStructure', 'Direct form I', 'Arithmetic', 'double', 'Structure', 'Direct form I', 'opt', {'Window', hamming(window_size)});
end
original_signal = % Your original signal;
watermarked_signal = % Your watermarked signal;

% Assuming watermark_length is known
watermark_length = 15; % Adjust based on your requirements

detected_watermark = detect_data(original_signal, watermarked_signal, watermark_length);


