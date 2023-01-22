function [c] = appendStruct(a,b)
    %APPENDSTRUCT Appends two structures ignoring duplicates
    %   Developed to append two structs while handling cases of non-unique
    %   fieldnames.  The default keeps the last occurance of the duplicates in
    %   the appended structure.
    ab = [struct2cell(a); struct2cell(b)];
    abNames = [fieldnames(a); fieldnames(b)];
    [~,iab] = unique(abNames,'last');
    c = cell2struct(ab(iab),abNames(iab));
end