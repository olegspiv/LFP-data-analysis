classdef LFPDataAnalysis
    properties
        % Duration of plot in seconds
        secs_to_plot = 10;
        % Lower limit for spectrogram of channel 2
        clim1 = -50;
        % Upper limit for spectrogram of channel 2
        clim2 = 6500;
        % Lower limit for spectrogram of channel 1
        clim3 = -50;
        % Upper limit for spectrogram of channel 1
        clim4 = 3000;
        % Use logarithmic scale if true
        lg = true;
        % Path to FieldTrip toolbox
        fieldtrip_path = 'path/to/the/fieldtrip';
        % Path to data containing .mat file
        data_source = 'your_data*.mat';
        % Names of channels to process
        signals = {'ch1', 'ch2'};
        % Sampling frequency in Hz
        fsample_hz = 256;
        % Maximum frequency for analysis in Hz
        freq_hz = 45;
        % Names of the channels
        channel_names = {'ch1', 'ch2'};
        % Description of the data
        info = 'Resting state LFP recordings';
        % Length of data segments in seconds
        segment_length_s = 60;
        % Overlap between data segments (fraction)
        overlap = 0;
        % High-pass filter cutoff frequency in Hz
        hp_cutoff_hz = 0.5;
        % Low-pass filter cutoff frequency in Hz
        lp_cutoff_hz = 45;
        % Bandstop filter frequency range in Hz
        bs_freq_hz = [49, 51];
        % Spectral analysis window length in seconds
        spectral_window_s = 0.5;
        % Smoothing frequency for spectral analysis in Hz
        smoothing_frequency_hz = 1;
        % Frequency range for power analysis in Hz
        power_frequency_range_hz = 1:1:45;
        % Lower limit for x-axis in spectrogram plots
        spectrogram_xlim_low_hz = 0;
        % Upper limit for x-axis in spectrogram plots
        spectrogram_xlim_high_hz = 45;
    end

    properties (Access = protected)
        % Processed data structure
        data;
        % Combined data from all channels
        combined_data;
        % Data from channel 1
        ch1_data;
        % Data from channel 2
        ch2_data;
    end

    methods (Access = public)
        function obj = LFPDataAnalysis()
            addpath(obj.fieldtrip_path);
            obj = obj.loadData();
        end

        function obj = preprocessData(obj)
            ft_defaults;

            % Segment data
            cfg = [];
            cfg.length = obj.segment_length_s;
            cfg.overlap = obj.overlap;
            data_segmented = ft_redefinetrial(cfg, obj.data);

            % Preprocess data
            cfg = [];
            cfg.demean = 'yes';
            cfg.lpfilter = 'yes';
            cfg.lpfreq = obj.lp_cutoff_hz;
            cfg.hpfilter = 'yes';
            cfg.hpfreq = obj.hp_cutoff_hz;
            cfg.bsfilter = 'yes';
            cfg.bsfreq = obj.bs_freq_hz;
            data_filtered = ft_preprocessing(cfg, data_segmented);

            % Time-frequency analysis
            cfg = [];
            cfg.output = 'pow';
            cfg.channel = 'all';
            cfg.method = 'mtmconvol';
            cfg.taper = 'hanning';
            cfg.foi = 1:2:obj.freq_hz;
            cfg.t_ftimwin = ones(length(cfg.foi), 1) .* obj.spectral_window_s;
            cfg.toi = 'all';
            tfr = ft_freqanalysis(cfg, data_filtered);

            obj.plotData(tfr);
        end

        function plotData(obj, tfr)
            cfg = [];
            cfg.baselinetype = 'db';
            cfg.pad = 'nextpow2';
            tfrbl = ft_freqbaseline(cfg, tfr);

            tick_spacing = length(tfrbl.freq) * 10 / obj.freq_hz;

            % Extract spectrograms
            channel1_spectrogram = squeeze(tfrbl.powspctrm(find(strcmp(tfrbl.label, 'ch1')), :, :));
            channel2_spectrogram = squeeze(tfrbl.powspctrm(find(strcmp(tfrbl.label, 'ch2')), :, :));

            smpl = 1;
            progress = 0;

            while smpl + obj.fsample_hz * obj.secs_to_plot < length(obj.combined_data)
                progress = progress + obj.secs_to_plot;

                figure;
                % Plot for Channel 1
                obj.plotChannel(1, smpl, channel1_spectrogram, tick_spacing);

                % Plot for Channel 2
                obj.plotChannel(2, smpl, channel2_spectrogram, tick_spacing);

                % Add annotation
                annotation('textbox', [0.47, 0.16, 0.18, 0.08], ...
                    'String', ['Progress: ' num2str(progress) ' out of ' num2str(round(length(obj.combined_data) / obj.fsample_hz))], ...
                    'LineStyle', 'none', 'FontSize', 18, 'FitBoxToText', 'off');

                % Interactive user input for proceeding or changing scale
                while true
                    c = input('Proceed to the next (1) or change the scale (2)? ');
                    if c == 1
                        clf;
                        break;
                    elseif c == 2
                        p = ginput(1);
                        ylim([0 p(2)]);
                        clear p;
                    end
                end

                smpl = smpl + obj.fsample_hz * obj.secs_to_plot;
            end

            close all;
        end
    end

    methods (Access = protected)
        function obj = loadData(obj)
            adir = dir(obj.data_source);

            for j = 1:numel(adir)
                rec = load(adir(j).name);
                fnames = fields(rec);

                if numel(obj.signals) == 2
                    s1 = eval(['rec.' fnames{1}]);
                    s2 = eval(['rec.' fnames{2}]);
                end
            end

            obj.ch1_data = s1.values;
            obj.ch2_data = s2.values;

            if length(obj.ch1_data) == length(obj.ch2_data)
                obj.combined_data(1, :) = obj.ch1_data;
                obj.combined_data(2, :) = obj.ch2_data;
            elseif length(obj.ch1_data) > length(obj.ch2_data)
                obj.combined_data(1, :) = obj.ch1_data(1:length(obj.ch2_data));
                obj.combined_data(2, :) = obj.ch2_data;
            else
                obj.combined_data(1, :) = obj.ch1_data;
                obj.combined_data(2, :) = obj.ch2_data(1:length(obj.ch1_data));
            end

            obj.data.trial{1} = obj.combined_data;
            obj.data.time{1} = linspace(0, length(obj.combined_data) / obj.fsample_hz, length(obj.combined_data));
            obj.data.label = obj.channel_names;
            obj.data.fsample = obj.fsample_hz;
            obj.data.addition_info = obj.info;
        end

        function powerLFPs = performSpectralPowerAnalysis(obj, data_cut)
            data1.trial{1} = data_cut;
            data1.time{1} = linspace(0, length(data_cut) / obj.fsample_hz, length(data_cut));
            data1.label = obj.channel_names;
            data1.fsample = obj.fsample_hz;
            data1.addition_info = obj.info;

            cfg = [];
            cfg.length = 1;
            cfg.overlap = obj.overlap;
            data_segmented1 = ft_redefinetrial(cfg, data1);

            cfg = [];
            cfg.demean = 'yes';
            cfg.lpfilter = 'yes';
            cfg.lpfreq = obj.lp_cutoff_hz;
            cfg.hpfilter = 'yes';
            cfg.hpfreq = obj.hp_cutoff_hz;
            cfg.bsfilter = 'yes';
            cfg.bsfreq = obj.bs_freq_hz;
            data_filtered1 = ft_preprocessing(cfg, data_segmented1);

            cfg = [];
            cfg.channel = 'all';
            cfg.method = 'mtmfft';
            cfg.tapsmofrq = obj.smoothing_frequency_hz;
            cfg.output = 'pow';
            cfg.taper = 'dpss';
            cfg.foi = obj.power_frequency_range_hz;
            cfg.keeptrials = 'no';
            cfg.polyremoval = -1;
            powerLFPs = ft_freqanalysis(cfg, data_filtered1);
        end

        function plotChannel(obj, channelIdx, smpl, spectrogram_data, tick_spacing)
            % Plot raw data
            subplot(2, 3, (channelIdx - 1) * 3 + 1);
            d = obj.combined_data(channelIdx, smpl:smpl + obj.fsample_hz * obj.secs_to_plot);
            plot(d);
            xlim([0 length(d)]);
            ylabel(['Raw LFP [microV] ', obj.channel_names{channelIdx}]);
            if channelIdx == 2
                xlabel('Time [s]');
            end
            box off;

            % Plot time-frequency representation
            subplot(2, 3, (channelIdx - 1) * 3 + 2);
            imagesc(spectrogram_data, [obj.(['clim', num2str(channelIdx)])]);
            xlim([smpl (smpl + obj.fsample_hz * obj.secs_to_plot)]);
            ylabel('Frequency [Hz]');
            ax = gca;
            ax.YDir = 'normal';
            ax.YTick = tick_spacing:tick_spacing:length(spectrogram_data);
            ax.YTickLabel = 10:10:obj.freq_hz;
            colorbar;
            if obj.lg
                set(gca, 'ColorScale', 'log');
            end
            if channelIdx == 2
                xlabel('Time [s]');
            end

            % Plot relative power
            subplot(2, 3, (channelIdx - 1) * 3 + 3);
            data_cut = obj.combined_data(channelIdx, smpl:obj.secs_to_plot * obj.fsample_hz + smpl);
            powerLFPs = obj.performSpectralPowerAnalysis(data_cut);
            plot(powerLFPs.powspctrm(1, :));
            xlim([obj.spectrogram_xlim_low_hz obj.spectrogram_xlim_high_hz]);
            ylabel('Relative Power');
            if channelIdx == 2
                xlabel('Frequency (Hz)');
            end
        end
    end
end

