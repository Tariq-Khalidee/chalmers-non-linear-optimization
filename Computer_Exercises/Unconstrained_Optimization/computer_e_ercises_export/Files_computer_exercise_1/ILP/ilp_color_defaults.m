function ilp_color_defaults(mode,fig)
%ILP_COLOR_DEFAULTS Replacement for the removed MATLAB function colordef.
%   ILP_COLOR_DEFAULTS('white') sets root defaults equivalent to the old
%   white color scheme used by the menu windows.
%
%   ILP_COLOR_DEFAULTS('black',FIG) applies a black-background color scheme
%   to FIG and its axes/text objects, equivalent to the old colordef none use
%   in rita.m. The implementation uses only graphics properties available in
%   MATLAB R2021a and later.

if nargin < 2
    fig = [];
end

mode = lower(mode);

switch mode
    case 'white'
        set(0, ...
            'DefaultFigureColor',[1 1 1], ...
            'DefaultAxesColor',[1 1 1], ...
            'DefaultAxesXColor',[0 0 0], ...
            'DefaultAxesYColor',[0 0 0], ...
            'DefaultAxesZColor',[0 0 0], ...
            'DefaultTextColor',[0 0 0]);
        if ~isempty(fig) && ishghandle(fig)
            apply_colors_to_figure(fig,[1 1 1],[0 0 0]);
        end

    case {'black','none'}
        if isempty(fig) || ~ishghandle(fig)
            fig = gcf;
        end
        set(fig, ...
            'Color',[0 0 0], ...
            'DefaultAxesColor',[0 0 0], ...
            'DefaultAxesXColor',[1 1 1], ...
            'DefaultAxesYColor',[1 1 1], ...
            'DefaultAxesZColor',[1 1 1], ...
            'DefaultTextColor',[1 1 1]);
        apply_colors_to_figure(fig,[0 0 0],[1 1 1]);

    otherwise
        error('Unknown color mode: %s',mode);
end
end

function apply_colors_to_figure(fig,bg,fg)
set(fig,'Color',bg);

ax = findall(fig,'Type','axes');
for k = 1:numel(ax)
    set(ax(k), ...
        'Color',bg, ...
        'XColor',fg, ...
        'YColor',fg, ...
        'ZColor',fg);
    ttl = get(ax(k),'Title');
    xl = get(ax(k),'XLabel');
    yl = get(ax(k),'YLabel');
    zl = get(ax(k),'ZLabel');
    set([ttl xl yl zl],'Color',fg);
end

txt = findall(fig,'Type','text');
for k = 1:numel(txt)
    set(txt(k),'Color',fg);
end
end
