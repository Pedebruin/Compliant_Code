function makeTXT(Objects)
%{
This function converts the parameters in the generated objects in PRBM.m in
a file equations.txt which can be read by SOLIDWORKS.
Inputs: 
    Objects - All properties of the joints and links in objects array. 
%}

for i = 1:length(Objects)                                                   % For every object
    object = Objects{i}.name;                                               % select name
    fields = fieldnames(Objects{i});                                        % get all fields
    for j = 2:numel(fields)                                                 % cycle through all fields
        field = fields{j};
        if ismember(field,['L','h','w','v','d','t','s','wmax','delta'])     % which fields do you want?
            value = num2str(getfield(Objects{i},field));                    % Get value of field

            % set . or _ (syntax conversion)
            if upper(object) == object
                objectField = strcat(object,'.',field);
            else
                objectField = strcat(object,'_',field);
            end

            % set unit
            unit = 'm'; % m unless overwritten
            
            if strcmp(field,'delta')        % for delta chose different unit. 
                unit= [];
                value = num2str(rad2deg(eval(value)));
            end
            
            % make nice string in proper format
            current = strcat('"',objectField,'"','=',{' '},value,unit);    

            % write string into array
            if exist('parameters','var')
                parameters = [parameters; current];
            else
                parameters = string(current);
            end
        end
    end
end

% write array into .txt file 
fileID = fopen('./Fem_files/user_files/equations.txt','wt');
formatSpec = '%s\n';
fprintf(fileID,formatSpec,parameters);
end