for x=1:length(TrainingInputs)
    inp = dot(TrainingOutputs(:,x),[0; 1; 2; 3; 4; 5]);
    file = "TrainingInputs"+inp;
    allOneString = sprintf('%f, ' , TrainingInputs(:,x));
    allOneString = allOneString(1:end-2);% strip final comma
    regexp(allOneString,'[^""]*','match','once');
    writematrix(allOneString,file+".csv",'Delimiter','comma','WriteMode','append');
    % This is actually newline as writematrix appends not commas
end