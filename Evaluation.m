clc;
clear;
%% evaluate deep learning model
prediction_path = '../predictions/';
pred_folder= dir(prediction_path);
pred_file={pred_folder.name};
dice_coef_dl = zeros(1, length(pred_file)-3);
case_name_list = zeros(1, length(pred_file)-3);
for num_pred= 4 : length(pred_file)
    case_name = pred_file(num_pred);
    case_name = char(case_name);
    finishing = [num2str(num_pred-3),'/',num2str(length(pred_file)-3)];
    disp(finishing)
    disp(case_name)
    mat = load([prediction_path, case_name, '/predictions.mat']);
    mask = mat.mask;
    pred = mat.pred;
    [~, ~, n3] = size(mask);
    dice = 0;
    for i = 1 : n3
        imshow(pred(:,:,i))
        dice_single = dice(mask(:,:,i), pred(:,:,i));
        dice = dice + dice_single;
    end
    dice = dice/n3;
    dice_coef_dl(num_pred-3) = dice;
    case_name_list(num_pred-3) = case_name;
end

%% evaluate brainsuite
prediction_path = '../predictions_brainsuite/';
pred_folder= dir(prediction_path);
pred_file={pred_folder.name};
dice_coef_bse = zeros(1, length(pred_file)-3);
for num_pred= 4 : length(pred_file)
    case_name = pred_file(num_pred);
    case_name = char(case_name);
    finishing = [num2str(num_pred-3),'/',num2str(length(pred_file)-3)];
    disp(finishing)
    disp(case_name)
    mat = load([prediction_path, case_name, '/predictions.mat']);
    mask = mat.mask;
    pred = mat.pred;
    [~, ~, n3] = size(mask);
    dice = 0;
    for i = 1 : n3
        imshow(pred(:,:,i))
        dice_single = dice(mask(:,:,i), pred(:,:,i));
        dice = dice + dice_single;
    end
    dice = dice/n3;
    dice_coef_bse(num_pred-3) = dice;
end



%% plot
x = case_name_list;
y = [dice_coef_dl; dice_coef_bse]';
barh(x,y)
xlabel('Case Name')
ylabel('Dice Coefficient')
lengend({'Deep Learning Model', 'Brainsuite'})
