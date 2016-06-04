function binaryImage = imThreshold(Im, threshold)
        %% thresholding images based on Ridler Calvard
        %         Reference: [1]. T. W. Ridler, S. Calvard, Picture thresholding using an iterative selection method, 
%            IEEE Trans. System, Man and Cybernetics, SMC-8, pp. 630-632, 1978.
%         [threshold, ~] = isodata(Im);

        IBW = ones(size(Im));
        IBW(threshold<= Im) = 0;
        
        % BW fill
        binaryImage = imfill(IBW);
