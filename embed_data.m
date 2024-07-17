clear all;
close all;
F = 500;
fs = 5000;
Ts = 1/fs;
t = 0:Ts:5;  % Time vector
input_signal = sin(2*pi*F*t);
watermark_data = '010010101100110'; % Your watermark data

watermarked_signal = embeddata(input_signal, watermark_data);
function watermarked_signal = embeddata(input_signal, watermark_data)
    % Data embedding process
    
    % Step 1: Design IIR all-pass filters H0(z) and H1(z)
    b0 = 0.795;
    b1 = 0.865;
    
    % Define the filters
    H0 = dfilt.df2(allpass(b0));
    H1 = dfilt.df2(allpass(b1));
    
    % Step 2: Filter the original signal in parallel systems
    w0 = filter(H0, original_signal);
    w1 = filter(H1, original_signal);
    
    % Step 3: Set embedded data
    embedded_data = str2num(watermark_data(:)')'; % Convert string to numeric array
    
    % Step 4: Select intermediate signal based on embedded data
    watermarked_signal = (embedded_data == 0) .* w0 + (embedded_data == 1) .* w1;
end

function Hd = allpass(b)
    % Design an all-pass filter using given coefficient b
    
    % Coefficients for the all-pass filter
    a = 1;
    
    % Design the filter
    Hd = dfilt.df2(a, b);
end



