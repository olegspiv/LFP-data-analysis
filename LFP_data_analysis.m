%% Adjust plot settings
secs_to_plot = 10;

% color limits for the upper plot
clim1 = -50;
clim2 = 6500;

% color limits for the lower plot
clim3 = -50;
clim4 = 3000;

% set 1 for logarhithic scale
lg = 1;

%%
addpath('path/to/the/fieldtrip') % path to the fieldtrip tool
adir =  dir('your_data*.mat'); % path to the .mat file containing your recorded data
signals = {'ch1','ch2'};

for j =1:numel(adir)
    rec=load(adir(j).name);
    fnames = fields(rec);
    if numel(signals)==2
        s1 = eval(['rec.' fnames{1,1}]);
        s2 = eval(['rec.' fnames{2,1}]);
    end
end

ch1_data = s1.values;
ch2_data = s2.values;

if length(ch1_data) == length(ch2_data)
    all(1,:) = ch1_data;
    all(2,:) = ch2_data;
elseif length(ch1_data) > length(ch2_data)
    all(1,:) = ch1_data(1:length(ch2_data));
    all(2,:) = ch2_data(1:length(ch2_data));
elseif length(ch1_data) < length(ch2_data)
    all(1,:) = ch1_data(1:length(ch1_data));
    all(2,:) = ch2_data(1:length(ch1_data));
end

info = 'Resting state LFP recordings';
fsample = 256;
freq = 45;
channel_names = {'ch1', 'ch2'};
data.trial{1} = all;
data.time{1} = linspace(0,length(all)/fsample,length(all));
data.label = channel_names;
data.fsample = fsample;
data.addition_info = info;

ft_defaults

% segment data
cfg = [];
cfg.length = 60; % create segments of 60 seconds each
cfg.overlap = 0; % 0.5
data_segmented = ft_redefinetrial(cfg, data);

% preprocess data
cfg = [];
cfg.demean     = 'yes'; % 'no' or 'yes', whether to apply baseline correction (default = 'no')
cfg.lpfilter   = 'yes'; % 'no' or 'yes'  lowpass filter (default = 'no')
cfg.lpfreq     =  freq; % lowpass  frequency in Hz
cfg.hpfilter   = 'yes'; % 'no' or 'yes'  highpass filter (default = 'no')
cfg.hpfreq     = .5; % highpass frequency in Hz
cfg.bsfilter   = 'yes'; % 'no' or 'yes'  bandstop filter (default = 'no')
cfg.bsfreq     = [49 51]; %  bandstop frequency range, specified as [low high] in Hz (or as Nx2 matrix for notch filter)
data_filtered = ft_preprocessing(cfg,data_segmented);

% to create the time-frequency plot
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:2:freq;                       % analysis 2 to 45 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = 'all';
tfr = ft_freqanalysis(cfg,data_filtered);


%% Plotting using the Matlab tool
clear a b a1 b1 data1 powerLFPs data_filtered1 data_segmented1 data_cut
figure
smpl = 1;
kama = 0;

cfg               = [];
cfg.baselinetype  = 'db';
cfg.pad           = 'nextpow2';
tfrbl = ft_freqbaseline(cfg, tfr);

tick10 = length(tfrbl.freq)*10/freq;

% extract spectrogramm of channel 1
chanindx1 = find(strcmp(tfrbl.label, 'ch1'));
a1 = squeeze(tfrbl.powspctrm(chanindx1,:,:));
b1 = a1;

% extract spectrogramm of channel 2
chanindx2 = find(strcmp(tfrbl.label, 'ch2'));
a2 = squeeze(tfrbl.powspctrm(chanindx2,:,:));
b2 = a2;


%
while smpl + fsample*secs_to_plot < length (all)
    kama = kama + secs_to_plot;

    axes('Position',[0.0605461908617263 0.75534188034188 0.29205797580494 0.194798534798553]);
    d = ch1_data(smpl:smpl + fsample*secs_to_plot);
    plot(d)

    xlim([0 length(d)])
    ylabel('Raw LFP [microV] MCx')
    set(gca,'xtick',[]);
    set(gca,'xcolor',[1 1 1])
    box off
    clear d

    axes('Position',[0.0587232741950595 0.465277777777777 0.29205797580494 0.194798534798552]);
    d = ch2_data(smpl:smpl + fsample*secs_to_plot);
    plot(d)

    xlim([0 length(d)])
    ylabel('Raw LFP [microV] STN')
    xlabel('Time [s]')
    box off

    ax = gca;
    ax.XTick = 0:fsample:fsample*secs_to_plot;
    ax.XTickLabel = [0:1:secs_to_plot];
    clear d

    axes('Position',[0.424869107528393 0.749732905982906 0.29205797580494 0.194798534798553]);

    imagesc(b1, [clim3, clim4]);
    xlim([smpl (smpl + fsample*secs_to_plot)])

    ax = gca;
    ax.YDir = 'normal';
    ax.YTick = tick10:tick10:length(tfrbl.freq);
    ax.YTickLabel = [10:10:40];
    set(gca,'xtick',[]);
    set(gca,'xcolor',[1 1 1])

    ylabel('Frequency [Hz]')
    colorbar
    if lg == 1
        set(gca,'ColorScale','log')
    end

    axes('Position',[0.423046190861726 0.459668803418801 0.296224642471607 0.194798534798552]);

    imagesc(b2,[clim1, clim2]);
    xlim([smpl (smpl + fsample*secs_to_plot)])

    ax = gca;
    ax.YDir = 'normal';
    ax.XTick = smpl:fsample:smpl + fsample*secs_to_plot;
    ax.XTickLabel = 0:1:secs_to_plot;

    ax.YTick = tick10:tick10:length(tfrbl.freq);
    ax.YTickLabel = [10:10:40];

    ylabel('Frequency [Hz]')
    xlabel('Time [s]')
    colorbar
    if lg == 1
        set(gca,'ColorScale','log')
    end

    data_cut(1,:) = all(1,smpl:secs_to_plot*fsample+smpl);
    data_cut(2,:) = all(2,smpl:secs_to_plot*fsample+smpl);

    data1.trial{1} = data_cut; %double(rawdata');
    data1.time{1} = linspace(0,length(data_cut)/fsample,length(data_cut));
    data1.label = channel_names;
    data1.fsample = fsample;
    data1.addition_info = info;

    % segment data
    cfg = [];
    cfg.length = 1; % create segments of 1 seconds each
    cfg.overlap = 0; % 0.5
    data_segmented1 = ft_redefinetrial(cfg, data1);

    % preprocess data
    cfg = [];
    cfg.demean     = 'yes'; % 'no' or 'yes', whether to apply baseline correction (default = 'no')
    cfg.lpfilter   = 'yes'; % 'no' or 'yes'  lowpass filter (default = 'no')
    cfg.lpfreq     =  freq; % lowpass  frequency in Hz
    cfg.hpfilter   = 'yes'; % 'no' or 'yes'  highpass filter (default = 'no')
    cfg.hpfreq     = .5; % highpass frequency in Hz
    cfg.bsfilter   = 'yes'; % 'no' or 'yes'  bandstop filter (default = 'no')
    cfg.bsfreq     = [49 51]; %  bandstop frequency range, specified as [low high] in Hz (or as Nx2 matrix for notch filter)
    data_filtered1 = ft_preprocessing(cfg,data_segmented1);

    %spectral analysis
    cfg = [];
    cfg.channel = 'all';
    cfg.method    = 'mtmfft';
    cfg.tapsmofrq = 1; %  the amount of spectral smoothing through multi-tapering.
    cfg.output    = 'pow'; %  return the power-spectra
    cfg.taper     = 'dpss'; % discrete prolate spheroidal sequences
    cfg.foi       = 1:1:freq;
    cfg.keeptrials='no'; % return individual trials or average (default = 'no')
    cfg.polyremoval = -1; % no demeaning
    powerLFPs= ft_freqanalysis(cfg, data_filtered1);

    axes('Position',[0.806900357528391 0.747329059829059 0.133724642471608 0.194798534798553]);
    % plot (powerLFPs.powspctrm(1,:)./max(powerLFPs.powspctrm(1,:)))
    plot (powerLFPs.powspctrm(1,:))
    ylabel('Relative Power')
    xlim([0 45])
    % grid on
    % set(gca, 'YScale', 'log')

    axes('Position',[0.807160774195055 0.457532051282049 0.133724642471608 0.194798534798552]);
    % plot (powerLFPs.powspctrm(2,:)./max(powerLFPs.powspctrm(2,:)))
    plot (powerLFPs.powspctrm(2,:))
    xlabel('Frequency (Hz)'),ylabel('Relative Power')
    xlim([0 45])
    % set(gca, 'YScale', 'log')

    annotation('textbox',...
        [0.470442708333331 0.155982905982906 0.181249999999997 0.0871410256410256],...
        'String',['Progress: ' num2str(kama) ' out of ' num2str(round(length(all)/256))],...
        'LineStyle','none',...
        'FontSize',18,...
        'FitBoxToText','off');

    smpl = smpl + fsample*secs_to_plot;

    while 1
        c = input('proceed to the next (1) or change the scale (2)? ');
        if c == 1
            clf
            break
        elseif c == 2

            p = ginput(1);
            ylim ([0 p(2)])
            clear p
        end
    end

    clear data1 powerLFPs data_filtered1 data_segmented1 data_cut
end
close all