function makeTXT(Objects)
% makes a txt file named 'equations.txt' with the important parameters. 
% Generate cell array with proper names and values!
for i = 1:length(Objects)
    object = Objects{i}.name;
    fields = fieldnames(Objects{i});
    for j = 2:numel(fields)
        field = fields{j};
        if ismember(field,['L','h','w','v','d','wmax','delta'])                % which fields do you want
            value = num2str(getfield(Objects{i},field));

            % set . or _
            if upper(object) == object
                objectField = strcat(object,'.',field);
            else
                objectField = strcat(object,'_',field);
            end

            % set unit
            unit = 'm';
            
            if strcmp(field,'delta')
                unit= [];
                value = num2str(rad2deg(eval(value)));
            end
            current = strcat('"',objectField,'"','=',{' '},value,unit);     % get proper formatting

            % write into array
            if exist('parameters','var')
                parameters = [parameters; current];
            else
                parameters = string(current);
            end
        end
    end
end

fileID = fopen('equations.txt','wt');
formatSpec = '%s\n';
fprintf(fileID,formatSpec,parameters);

end