function data = openStdCSV(fullfile)
    % Input must be a valid CSV filname (including path if not in current folder).
    %   The CSV file must have one DATA block
    %       By convention, the first row is strings (categories, names, etc - must start with a
    %       number) and the rows below are (meta)data. 
    % Output is a struct with (potential) fields: 'raw', 'table', 'structured', 'key'
    %   The presence of 'structured' and 'key' depends on CSV components
    %       'structured' comes from TREE block
    %           each 'd' (data) child must point to a 'c' (category) parent, cannot point to 0
    %           'c' childs must point to a 'c' parent or 0.
    %       'key' comes from KEY block
    
    % Check input
    validateattributes(fullfile, {'char'}, {}, mfilename, 'fullfile', 1);
    if ~strcmpi(fullfile(end-3: end), '.csv')
        fullfile = strcat(fullfile, '.csv');
    end
    
    % Open file
    fileID = fopen(fullfile, 'rt');
    
    % Find block indices and extract data
    blocks = struct();
    i = 0;
    while true
        i = i + 1;
        line = fgetl(fileID);
        if ischar(line)
            split = regexp(line, ',', 'split');
            rawFile(i, :) = split; %#ok<AGROW>
            switch split{1}
                case 'BEGINDATA'
                    blocks.BEGINDATA = i;
                case 'ENDDATA'
                    blocks.ENDDATA = i;
                case 'BEGINKEY'
                    blocks.BEGINKEY = i;
                case 'ENDKEY'
                    blocks.ENDKEY = i;
                case 'BEGINTREE'
                    blocks.BEGINTREE = i;
                case 'ENDTREE'
                    blocks.ENDTREE = i;
            end
        else
            break
        end
    end
        
    % Prepare output data struct array
    data = struct();
    
    % Verify data block exists in file and extract
    if (isfield(blocks, 'BEGINDATA') && isfield(blocks, 'ENDDATA'))
        i1 = blocks.BEGINDATA + 2;
        i2 = blocks.ENDDATA - 1;
        raw = rawFile(i1:i2, :);
        headers = rawFile(i1 - 1, :);
        data.raw = [headers; raw];
        dataTable = cell2table(raw, 'VariableNames', headers);
        data.table = dataTable;
    else
        error('File must contain a DATA block')
    end
    
    % Extract key information, if applicable
    if (isfield(blocks, 'BEGINKEY') && isfield(blocks, 'ENDKEY'))
        key = struct();
        i1 = blocks.BEGINKEY + 1;
        i2 = blocks.ENDKEY - 1;
        for i = i1:i2
            key.(rawFile{i, 1}) = rawFile{i, 2};
        end
        data.key = key;
    end
    
    % Extract tree building information, if applicable
    if (isfield(blocks, 'BEGINTREE') && isfield(blocks, 'ENDTREE'))
        structured = struct();
        i1 = blocks.BEGINTREE + 1;
        i2 = blocks.ENDTREE - 1;
        treeData = rawFile(i1:i2, :);
        
        % Extract information based on tree data
        edges = cellStr2mat(treeData(:, 2));
        dataCols = strcmpi(treeData(:, 3), 'd');
        
        % Build tree
        uniqueEdges = unique(edges(dataCols));
        for uniqueEdge = uniqueEdges
            uniqueDataCols = (dataCols & (edges == uniqueEdge));
            s = table2struct(dataTable(:, uniqueDataCols));
            buildTree(s, uniqueEdge, 1:length(s));
        end
        data.structured = structured;
    end
    
    % This inner funciton recursively builds the data tree structure
    function buildTree(child, node, indexes)
        
        newNode = edges(node);
        if newNode == 0
            % Base case
            k = 0;
            for j = indexes
                k = k + 1;
                structured.(strcat(headers{node}, '_', raw{j, node})) = child(k);
            end
        else
            [uniqueCategories, uniqueIndexes] = unique(raw(indexes, newNode));
            categories = struct();
            for j = 1:length(uniqueCategories)
                uniqueCategIdx = strcmp(raw(indexes, newNode), uniqueCategories(j));
                for k = find(uniqueCategIdx)'
                    categories(j).(strcat(headers{node}, '_', raw{k, node})) = child(k);
                end
            end
            buildTree(categories, newNode, uniqueIndexes');
        end
    end
end


