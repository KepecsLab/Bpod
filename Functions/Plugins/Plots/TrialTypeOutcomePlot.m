%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2015 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
% function OutcomePlot(AxesHandle,TrialTypeSides, OutcomeRecord, CurrentTrial)
function TrialTypeOutcomePlot(AxesHandle, Action, varargin)
%% 
% Plug in to Plot trial type and trial outcome.
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
% TrialTypeOutcomePlot(AxesHandle,'init',TrialTypes)
% TrialTypeOutcomePlot(AxesHandle,'init',TrialTypes,'ntrials',90)
% TrialTypeOutcomePlot(AxesHandle,'update',CurrentTrial,TrialTypes,OutcomeRecord)

% varargins:
% TrialTypes: Vector of trial types (integers)
% OutcomeRecord:  Vector of trial outcomes
%                 Simplest case: 
%                               1: correct trial (green)
%                               0: incorrect trial (red)
%                 Advanced case: 
%                               NaN: future trial (blue)
%                                -1: withdrawal (red circle)
%                                 0: incorrect choice (red dot)
%                                 1: correct choice (green dot)
%                                 2: did not choose (green circle)
% OutcomeRecord can also be empty
% Current trial: the current trial number

% Adapted from BControl (SidesPlotSection.m) 
% Kachi O. 2014.Mar.17
% J. Sanders. 2015.Jun.6 - adapted to display trial types instead of sides

%% Code Starts Here
global nTrialsToShow %this is for convenience
global BpodSystem

switch Action
    case 'init'
        %initialize pokes plot
        TrialTypeList = varargin{1};
        
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin > 3 %custom number of trials
            nTrialsToShow =varargin{3};
        end
        axes(AxesHandle);
        MaxTrialType = max(TrialTypeList);
        
        
        % Fitz mod note- 2 ways to determine trial types on the fly, one is to preallocate
        % trial types and outcomes with NaNs and then fill them in as you
        % go, second is to build trial type and outcome lists by accretion
        if isempty(MaxTrialType) || isnan(MaxTrialType)
            MaxTrialType = 1; % for NaN filled TrialTypes, might occur if you determine trial type on the fly
        end
        %plot in specified axes
        Xdata = 1:min(nTrialsToShow, length(TrialTypeList)); Ydata = -TrialTypeList(Xdata);
        BpodSystem.GUIHandles.FutureTrialLine = line([Xdata,Xdata],[Ydata,Ydata],'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.CurrentTrialCircle = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.CurrentTrialCross = line([0,0],[0,0], 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.UnpunishedErrorLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.PunishedErrorLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.RewardedCorrectLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.UnrewardedCorrectLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.NoResponseLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace',[1 1 1], 'MarkerSize',6);
        set(AxesHandle,'TickDir', 'out','YLim', [-MaxTrialType-.5, -.5], 'YTick', -MaxTrialType:1:-1,'YTickLabel', strsplit(num2str(MaxTrialType:-1:-1)), 'FontSize', 16);
        xlabel(AxesHandle, 'Trial#', 'FontSize', 18);
        ylabel(AxesHandle, 'Trial Type', 'FontSize', 16);
        hold(AxesHandle, 'on');
        
    case 'update'
        CurrentTrial = varargin{1};
        TrialTypeList = varargin{2};
        OutcomeRecord = varargin{3};
        MaxTrialType = max(TrialTypeList);
        if isnan(MaxTrialType)
            MaxTrialType = 1; % for NaN filled TrialTypes, this if statement shouldn't in practice be reached when using 'update' as opposed to 'init'
        end
        set(AxesHandle,'YLim',[-MaxTrialType-.5, -.5], 'YTick', -MaxTrialType:1:-1,'YTickLabel', strsplit(num2str(MaxTrialType:-1:-1)));
        if CurrentTrial<1
            CurrentTrial = 1;
        end
        TrialTypeList  = -TrialTypeList;
        % recompute xlim
        if length(TrialTypeList) > CurrentTrial % trial types are pre-determined
            [mn, mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow);
        else % if trial types are not predetermined, have graph end at current trial
            mn = max(1, CurrentTrial - nTrialsToShow + 1);
            mx = CurrentTrial;
        end
        
        
        %axes(AxesHandle); %cla;
        %plot future trials
        FutureTrialsIndx = CurrentTrial:mx;
        Xdata = FutureTrialsIndx; Ydata = TrialTypeList(Xdata);
        set(BpodSystem.GUIHandles.FutureTrialLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
        %Plot current trial
        set(BpodSystem.GUIHandles.CurrentTrialCircle, 'xdata', [CurrentTrial,CurrentTrial], 'ydata', [TrialTypeList(CurrentTrial),TrialTypeList(CurrentTrial)]);
        set(BpodSystem.GUIHandles.CurrentTrialCross, 'xdata', [CurrentTrial,CurrentTrial], 'ydata', [TrialTypeList(CurrentTrial),TrialTypeList(CurrentTrial)]);
        
        %Plot past trials
        if ~isempty(OutcomeRecord)
            indxToPlot = mn:CurrentTrial-1;
            %Plot Error, unpunished
            EarlyWithdrawalTrialsIndx =(OutcomeRecord(indxToPlot) == -1);
            Xdata = indxToPlot(EarlyWithdrawalTrialsIndx); Ydata = TrialTypeList(Xdata);
            set(BpodSystem.GUIHandles.UnpunishedErrorLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            %Plot Error, punished
            InCorrectTrialsIndx = (OutcomeRecord(indxToPlot) == 0);
            Xdata = indxToPlot(InCorrectTrialsIndx); Ydata = TrialTypeList(Xdata);
            set(BpodSystem.GUIHandles.PunishedErrorLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            %Plot Correct, rewarded
            CorrectTrialsIndx = (OutcomeRecord(indxToPlot) == 1);
            Xdata = indxToPlot(CorrectTrialsIndx); Ydata = TrialTypeList(Xdata);
            set(BpodSystem.GUIHandles.RewardedCorrectLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            %Plot Correct, unrewarded
            UnrewardedTrialsIndx = (OutcomeRecord(indxToPlot) == 2);
            Xdata = indxToPlot(UnrewardedTrialsIndx); Ydata = TrialTypeList(Xdata);
            set(BpodSystem.GUIHandles.UnrewardedCorrectLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            %Plot DidNotChoose
            DidNotChooseTrialsIndx = (OutcomeRecord(indxToPlot) == 3);
            Xdata = indxToPlot(DidNotChooseTrialsIndx); Ydata = TrialTypeList(Xdata);
            set(BpodSystem.GUIHandles.NoResponseLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
        end
end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end


