%% TODO list %%

% 1. add in sorting of behavioural data

%% define pipeline %%

% pipe = 2 ; % 1 = CON, 2 = FIX, 3 = IND

%% define BSR thrshold %%

% if ~exist('bsr_thr')
% 	bsr_thr = 3 ;
% end

%% added disp checks %%

disp(pipe)        ;
disp(bsr_thr)     ;
disp(OPPNI_dir)   ;
disp(behav_path)  ;
disp(filt)        ;
disp(outlier_ls)  ;
disp(output_path) ;
disp(output_name) ;

%% import behavioural data %%

behav_data = readtable(behav_path, 'ReadVariableNames',false) ;
behav_data = table2array(behav_data)                          ;

%% apply spatial mask %%

if exist('mask')
	disp('Preparing mask...') ;

	mask.raw       = load_nii(mask.path) ;
	mask.raw       = mask.raw.img ;
	mask.dims      = size(mask.raw) ;
	mask.img       = reshape(mask.raw, [1, prod(mask.dims)] ) ;
	mask.st_coords = find(mask.img) ;
	mask.zero      = zeros(size(mask.img)) ;
end

%% get spm data %%

OPPNI_dir = fullfile(OPPNI_dir, 'optimization_results', 'spms') ;

spm_ls       = dir(OPPNI_dir) ;
spm_ls       = {spm_ls(:).name} ;
spm_ls(1:2)  = [] ;
spm_ls_index = strfind(spm_ls, 'sNorm') ;
spm_ls_index = find(~cellfun(@isempty, spm_ls_index)) ;
spm_ls       = { spm_ls{ spm_ls_index } } ;

%% filter data %% (e.g., only data that includes a group prefix)

if exist('filt')
	spm_ls_index = strfind(spm_ls, filt) ;
	spm_ls_index = find(~cellfun(@isempty, spm_ls_index)) ;
	spm_ls       = { spm_ls{ spm_ls_index } } ;
end

%% sort runs %%

runs.exist = strfind(spm_ls, 'run') ;

if sum( [runs.exist{:}] ) > 0

	count = 0 ;
	runs.index = zeros(1, size(runs.exist,2) ) ;
	for file = spm_ls
		count = count + 1 ;

		tmp_runs = file{:}(runs.exist{count} + 3) ;
		tmp_runs = str2num(tmp_runs) ; 
		runs.index(count) = tmp_runs ;
	end

	runs.unique = unique(runs.index) ;

	%% sort data by runs %%

	spm_ls_sort{1} = 'null' ;
	for run = runs.unique
		tmp_spm_ls_sort       = strfind(spm_ls, ['run' num2str(run)])     ;
		tmp_spm_ls_sort_index = find(~cellfun(@isempty, tmp_spm_ls_sort)) ;
		tmp_spm_ls_sort       = { spm_ls{ tmp_spm_ls_sort_index } }       ;

		spm_ls_sort = {spm_ls_sort{:} tmp_spm_ls_sort{:}}                 ;
	end

	spm_ls_sort = {spm_ls_sort{2:end}} ;
	spm_ls      = spm_ls_sort ;

end

%% remove outliers %%

if exist('outlier_ls')

	outlier_ls = strsplit(outlier_ls, ';') ;

	outlier_index = 0 ;
	for outlier = outlier_ls
		outlier = outlier{:} ;
		% outlier = str2num(outlier) ;

		tmp_outlier_index = strfind(spm_ls, outlier) ;
		tmp_outlier_index = find(~cellfun(@isempty, tmp_outlier_index)) ;
		outlier_index     = [ outlier_index tmp_outlier_index ]   ;
	end
	outlier_index = outlier_index(2:end) ;

	spm_ls_outfree               = spm_ls(~ismember(spm_ls, spm_ls(outlier_index))) ;
	
	spm_ls                       = spm_ls_outfree ;
	behav_data(outlier_index, :) = [] ;

end

%% import imaging data %%

for spm = spm_ls
	spm = spm{:} ;
	spm = fullfile(OPPNI_dir, spm) ;
	spm = load_nii(spm) ;
	spm = spm.img ;
	spm = spm(:,:,:,pipe) ;
	spm = reshape(spm, [1, prod(size(spm))]) ;

	if ~exist('XX')
		XX = spm ;
	else
		XX = [XX;spm] ;
	end

end

%% threshold the XX matrix by the bsr_thr %%

XX(XX < bsr_thr) = 0 ;

%% define behavioural matrix %%

YY = behav_data ;

%% run PLS analysis %%

[avg_ZSalience_X,avg_ZSalience_Y,pred_scores_X, pred_scores_Y,pls_out] = pls_nasim(XX,YY,var_norm) ;

%% compile results in a single variable %%

pls_results.avg_ZSalience_X = avg_ZSalience_X ;
pls_results.avg_ZSalience_Y = avg_ZSalience_Y ;
pls_results.pred_scores_X   = pred_scores_X   ;
pls_results.pred_scores_Y   = pred_scores_Y   ;

pls_results.pls_out         = pls_out         ;
pls_results.subj_ls         = spm_ls          ;
pls_results.behav_data      = YY              ;

%% build output file path %%

output_path = fullfile(output_path, output_name) ;

%% save results to file %%

save(output_filename, pls_results) ;