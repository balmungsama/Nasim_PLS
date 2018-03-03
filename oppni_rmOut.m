date = datetime();
date = [num2str(date.Year), '.', num2str(date.Month), '.', num2str(date.Day), '_', num2str(date.Hour), '.', num2str(date.Minute)];

[status,user_scripts] = system('echo $JE_packages');
user_scripts =  regexprep(user_scripts,'[\n\r]+','');

addpath(fullfile(user_scripts, 'Nasim_PLS'));

cd(fullfile(user_scripts, 'Nasim_PLS'));

pipe = 2;
subj_path = '/global/home/hpc3586/SART_data/SART_behav/compiled_mat/outlier_rm.csv';
img_path  = '/global/home/hpc3586/SART_data/output/GO/Combined/detrend6_GO_sart_combined_erCVA/optimization_results/processed';

behavVars = {'mu', 'sigma', 'tau', 'err_NOGO'} ;
subjdata.table = readtable(subj_path); % subject behavioural data


%% get the imaging data paths %%
img_ls = dir(fullfile(img_path, '*sNorm.nii'));
img_ls = {img_ls.name}';

%% filter out the outliers %%

out.pattern = strcat('\w*', num2str(subjdata.table.subj), '\w*', num2str(subjdata.table.run), '\w*');
out.pattern = char(strrep(cellstr(out.pattern),' ', ''));

out.log(1:size(img_ls,1)) = false;
for patt = 1:size(out.pattern,1)
	tmp.out.log = regexp(img_ls, strtrim(out.pattern(patt,:)), 'match');
	out.log(find(~cellfun(@isempty, tmp.out.log))) = true;
end

img_ls = {img_ls{out.log}}';

%% extract behavioural data from table %%

subjdata.behav = subjdata.table(:,behavVars);
subjdata.behav = table2array(subjdata.behav);

Y = subjdata.behav;

%% sort the imaging data into a matrix %%
for img = 1:numel(img_ls)
	tmp.img = load_nii(fullfile(img_path, img_ls{img}));
	tmp.img = tmp.img.img(:,:,:,pipe);
	tmp.row = reshape(tmp.img, [1 numel(tmp.img)]);
	
	X(img,:) = tmp.row ;
end

% 0= no normalization, directly use input values 
% 1= (column wise) mean centring  of X and Y 
% 2= zscore X and Y 
[result.avg_ZSalience_X, result.avg_ZSalience_Y, result.pred_scores_X, result.pred_scores_Y, result.pls_out] = pls_nasim(X, Y, 1);

save([date '__' 'plsResults.mat'], 'result')