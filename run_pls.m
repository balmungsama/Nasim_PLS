
OUTPUT_dir = '/home/hpc3586/JE_packages/Nasim_PLS/results'

OPPNI_dir  = '/home/hpc3586/SART_data/output/GO/Younger/processing_GO_sart_young_erCVA_JE_erCVA' ;
BEHAV_dir  = '/home/hpc3586/SART_data/SART_behav/Younger' ;
BEHAV_vars = {'meanRT_GO'} ;
PIPE       = 2 ; % 1 = CON, 2 = FIX, 3 = IND
VAR_NORM   = 2 ;

% var_norm = mean centering/normalization method applied to both X
%            and Y matrices  
%
%        0 = no normalization, directly use input values 
%        1 = (column wise) mean centring  of X and Y 
%        2 = zscore X and Y

%% build file paths %%

OPPNI_dir = fullfile(OPPNI_dir, 'optimization_results', 'spms') ;

behav_ls      = dir(BEHAV_dir) ;
behav_ls      = {behav_ls(:).name} ;
behav_ls(1:2) = [] ;

spm_ls      = dir(OPPNI_dir) ;
spm_ls      = {spm_ls(:).name} ;
spm_ls(1:2) = [] ;

%% ex-Gaussian measures %%

exG_measures = {'mu', 'sigma', 'tau'} ;

%% prep for X & Y matrices %%

XX      = [] ;
YY      = [] ;
SUBJ_ls = {} ;

run_count = 0 ;
for subj = behav_ls

	subj_behav = subj{:} ;
	subj_behav = fullfile(BEHAV_dir, subj_behav) ;
	
	[pathstr,subj_id,ext] = fileparts(subj_behav) ; clear pathstr ext
	
	load(subj_behav) ;

	%% iterate through runs %%

	RUNS = [SART_behav.Runs]' ;
	RUNS = double(RUNS) ;
	for RUN = RUNS

		run_count = run_count + 1 ;

		%% find the matching NIFTI file %%		

		nifti_find  = regexp(spm_ls, ['\w*' subj_id '\w*run' num2str(RUN) '\w*sNorm.nii' ]) ;
		nifti_count = 0 ;

		for nifti = nifti_find ;
			nifti_count = nifti_count + 1 ;
			nifti = nifti{:} ;

			if nifti == 1
				nifti_index = nifti_count ;
				break
			end

		end

		spm = spm_ls{nifti_index} ;
		spm = fullfile(OPPNI_dir, spm) ;
		spm = load_nii(spm) ;
		spm = spm.img ;
		spm = spm(:,:,:, PIPE) ;														 % TODO: change this so that you can perform teh analysis on CON, FIX, and IND pipelines
		spm = reshape(spm, [1, prod(size(spm))]) ;
		spm = double(spm) ;

		XX(run_count,:) = spm ;

		%% iterate through behavioural measures %%

		behav_count = 0 ;
		for behav = BEHAV_vars

			behav = behav{:} ;

			behav_count = behav_count + 1 ;

			if any(strcmp(exG_measures, behav)) 
				YY(run_count, behav_count) = SART_behav.exGauss.(behav)(RUN) ;
			else
				YY(run_count, behav_count) = SART_behav.(behav)(RUN) ;
			end

		end

	SUBJ_ls{run_count,1} = subj_id ;
	SUBJ_ls{run_count,2} = RUN ;

	end	

end

[avg_ZSalience_X,avg_ZSalience_Y,pred_scores_X, pred_scores_Y,pls_out] = pls_nasim(XX, YY, VAR_NORM) ;

results.avg_ZSalience_X = avg_ZSalience_X ;
results.avg_ZSalience_Y = avg_ZSalience_Y ;
results.pred_scores_X   = pred_scores_X   ;
results.pred_scores_Y   = pred_scores_Y   ;
results.pls_out         = pls_out         ;

output_file = ['Younger', '.mat'] ;
output_file = fullfile(OUTPUT_dir, output_file) ;

save(output_file, 'results') ;

exit