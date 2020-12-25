itr = 0.5;
for x=1:itr:5
    file = "TrainingInputsDecimal"+x;
    mat = load(file+".mat");
    csvwrite(file+".csv",mat.TrainingInputs);
end

