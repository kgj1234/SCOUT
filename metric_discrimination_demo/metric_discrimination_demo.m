%This demo demonstrates how to determine the similarity of temporal/spatial
%metrics within and between sessions

load(fullfile('..','extraction_1','neurons'))
load(fullfile('..','extraction_1','links'))

%Within session similarity
disp('Within Session')
similarity=construct_similarity_statistics_within_sessions(neurons{1});

disp('same neuron SNR difference')
median(similarity.snr.closest)
disp('neighbor neuron SNR difference')
median(similarity.snr.one_nn)
disp('ratio: should be less than one')
median(similarity.snr.closest)/median(similarity.snr.one_nn)

disp('same neuron decay difference')
median(similarity.decay.closest)
disp('neighbor neuron decay difference')
median(similarity.decay.one_nn)
disp('ratio: should be less than one')
median(similarity.decay.closest)/median(similarity.decay.one_nn)


%Within session similarity
disp('Between Session')
similarity=construct_similarity_statistics_between_sessions(neurons{1},neurons{2},links{1},498,'1p');

disp('closest neuron SNR difference')
median(similarity.snr.closest)
disp('neighbor neuron SNR difference')
median(similarity.snr.one_nn)
disp('ratio: should be less than one')
median(similarity.snr.closest)/median(similarity.snr.one_nn)


disp('closest neuron decay difference')
median(similarity.decay.closest)
disp('neighbor neuron decay difference')
median(similarity.decay.one_nn)
disp('ratio: should be less than one')
median(similarity.decay.closest)/median(similarity.decay.one_nn)


disp('closest neuron temporal correlation')
median(similarity.corr.closest)
disp('neighbor neuron temporal correlation')
median(similarity.corr.one_nn)
disp('ratio: should be greater than one')
median(similarity.corr.closest)/median(similarity.corr.one_nn)