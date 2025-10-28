% Source Coding
% Task 2
clear all; close all; clc;
addpath("library_p\");

% Load the input image
lorem_img = imread('lorem_img.png');

% display the raw image
figure(1); clf;
imshow(lorem_img);
title('Original image');

% run-length encode
run_length_code = runlength_encode(lorem_img);
% convert the binary array into an decimal array of runs
runs = bin2decArray(run_length_code);

% huffman code        
% compute the probability of the run lengths .
rlen_list = [0:10,255];
figure(2);clf;
hist = histogram(runs,rlen_list,'Normalization','probability','Visible','off');
% show the probability
prob = hist.Values
prob = prob / sum(prob);
symbols = 0:10;


% Baue Huffman-Baum
nodes = num2cell(symbols);
weights = prob;

while numel(weights) > 1
    % sortiere nach Gewicht
    [weights, idx] = sort(weights);
    nodes = nodes(idx);

    % kombiniere zwei kleinste
    left = nodes{1};
    right = nodes{2};
    newNode = {left, right};

    % neues Gewicht und Knotenliste
    newWeight = weights(1) + weights(2);
    weights = [newWeight, weights(3:end)];
    nodes = [{newNode}, nodes(3:end)];
end



% Erzeuge Codes
dict = makeCode(nodes{1}, []);

% sichere Zeilenvektoren
for i = 1:length(dict)
    dict{i} = dict{i}(:)'; 
end

symbols = 0:10;
%prob = prob / sum(prob); % Sicherheitshalber normieren
nodes = num2cell(symbols);
weights = prob;
edges = [];
nodeNames = cellfun(@(x) num2str(x), nodes, 'UniformOutput', false);

while numel(weights) > 1
    [weights, idx] = sort(weights);
    nodes = nodes(idx);
    nodeNames = nodeNames(idx);

    left = nodes{1};
    right = nodes{2};
    newName = ['{' nodeNames{1} ',' nodeNames{2} '}'];
    edges = [edges; {newName, nodeNames{1}}; {newName, nodeNames{2}}];

    newNode = {left, right};
    newWeight = weights(1) + weights(2);
    weights = [newWeight, weights(3:end)];
    nodes = [{newNode}, nodes(3:end)];
    nodeNames = [{newName}, nodeNames(3:end)];
end

% Baum als gerichteten Graph darstellen
G = digraph(edges(:,1), edges(:,2));
figure(4);
plot(G,'Layout','layered','Direction','down','NodeLabel',G.Nodes.Name)
title('Huffman Tree for Optimal Dictionary');

% Bild speichern (im aktuellen Arbeitsordner)
saveas(gcf, 'HuffmanTree.png');
disp('Huffman tree saved as HuffmanTree.png');
% ---------------------------------------------------------------------
% show the probability using the function bar 
bar([0:10],prob); xlabel('run length'); ylabel('Probability');
set(gca,'XTickLabel',{'0','1','2','3','4','5','6','7','8','9','>=10'});
title('Histogram of the runs from 0 to 9 and >= 10');


     % % % % Revise the following code to generate a valid  and efficient dictionary   % % % %  
     %dict = {[0 0 0 0], [0 0 0 1], [0 0 1 0], [0 0 1 1], [0 1 0 0],...
        % [0 1 0 1], [0 1 1 0], [0 1 1 1], [1 0 0 0], [1 0 0 1],[1 0 1 0]};
       
    % % % % Do not change the code below % % % %  

% Use the dictionary to encode the run lengths
huffman = huffman_encode_dict(runs, dict);

% Decode
% Get the runs from the encoded bitstream
runs_new= huffman_decode_dict(huffman, dict) ;
new_length_code = reshape(dec2binArray(runs_new).',1,length(runs_new)*8);

% recreate 500 by 500 image from the run length code
img_new = runlength_decode(new_length_code);
figure(3);clf;
imshow(img_new);
title('Recreated image');

% Put figure  1 and 2 on top by calling them again
figure(2); 
figure(1);

% compare the lengths
size_raw_data = length(lorem_img(:))
size_huffman = length(huffman)
size_reconstructed = length(img_new(:))

% rekursive Funktion zum Erzeugen der Codes
function codeMap = makeCode(node, prefix)
    codeMap = cell(11,1);
    if iscell(node)
        % links -> 0, rechts -> 1
        leftMap = makeCode(node{1}, [prefix 0]);
        rightMap = makeCode(node{2}, [prefix 1]);
        for i = 1:11
            if ~isempty(leftMap{i}), codeMap{i} = leftMap{i}; end
            if ~isempty(rightMap{i}), codeMap{i} = rightMap{i}; end
        end
    else
        % Symbol gefunden
        codeMap{node+1} = prefix;
    end
end