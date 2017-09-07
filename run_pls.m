
% OUTPUT_dir = '/home/hpc3586/JE_packages/Nasim_PLS/results' ;
% OPPNI_dir  = '/home/hpc3586/SART_data/output/GO/Younger/processing_GO_sart_young_erCVA_JE_erCVA' ;
% BEHAV_dir  = '/home/hpc3586/SART_data/SART_behav/Younger' ;
% BEHAV_vars = {'meanRT_GO'} ;
% PIPE       = 2 ; % 1 = CON, 2 = FIX, 3 = IND
% VAR_NORM   = 2 ;

% var_norm = mean centering/normalization method applied to both X
%            and Y matrices  
%
%        0 = no normalization, directly use input values 
%        1 = (column wise) mean centring  of X and Y 
%        2 = zscore X and Y

% view input variables

disp(PREFIX)     ;
disp(OUTPUT_dir) ;
disp(OPPNI_dir)  ;
disp(BEHAV_dir)  ;
disp(BEHAV_vars) ;
disp(PIPE)       ;
disp(VAR_NORM)   ;

%% output thresholds %%

BSR_thr = 3 ;

%% build file paths %%

OPPNI_dir = fullfile(OPPNI_dir, 'optimization_results', 'spms') ;

GROUP = strsplit(BEHAV_dir, '/') ;
GROUP = GROUP{end} ;

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

disp('Compiling data...') ;

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

		if run_count == 1
			sample_spm                 = spm ;
			sample_spm.img             = sample_spm.img(:,:,:,1) ;
			sample_spm.hdr.dime.dim(5) = 1 ;
		end

		spm = spm.img ;
		spm = spm(:,:,:, PIPE) ;														 
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

disp('Running Behavioural PLS analysis') ;

[avg_ZSalience_X,avg_ZSalience_Y,pred_scores_X, pred_scores_Y,pls_out] = pls_nasim(XX, YY, VAR_NORM) ;

results.avg_ZSalience_X = avg_ZSalience_X ;
results.avg_ZSalience_Y = avg_ZSalience_Y ;
results.pred_scores_X   = pred_scores_X   ;
results.pred_scores_Y   = pred_scores_Y   ;
results.pls_out         = pls_out         ;

%% saving PLS results to .mat file %%

disp('Saving results...') ;

output_file = [PREFIX '_' GROUP, '_', BEHAV_vars{:}, '.mat'] ;
output_file = fullfile(OUTPUT_dir, output_file) ;

save(output_file, 'results') ;


%% extract & threshold BSRs %%

BS_ratios.raw                         = results.avg_ZSalience_X ;
BS_ratios.raw( isnan(BS_ratios.raw) ) = 0 ;

BS_ratios.thr                                 = BS_ratios.raw ;
BS_ratios.thr( abs(BS_ratios.thr) < BSR_thr ) = 0 ;

%% save BSR image %%
bsr_path = fullfile(OUTPUT_dir, [PREFIX '_' GROUP, '_', BEHAV_vars{:}, '__BSR', '.nii']) ;
sample_spm.img = reshape(BS_ratios.raw, size(sample_spm.img)) ;
save_nii(sample_spm, bsr_path)

%% save thr BSR image %%
bsr_thr_path = fullfile(OUTPUT_dir, [PREFIX '_' GROUP, '_', BEHAV_vars{:}, '__BSR_thr', '.nii']) ;
sample_spm.img = reshape(BS_ratios.thr, size(sample_spm.img)) ;
save_nii(sample_spm, bsr_thr_path)

exit