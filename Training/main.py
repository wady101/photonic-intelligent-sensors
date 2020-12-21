import math
import csv
import numpy
import os
import torch
import torch.nn as nn
from torch.utils.data.sampler import SubsetRandomSampler
import matplotlib.pyplot as plt
import pandas as pd
import itertools
from sklearn.metrics import confusion_matrix

def plot_confusion_matrix(cm, classes,
                          normalize=False,
                          cmap=plt.cm.Blues):
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, numpy.newaxis]
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.clim(0, 1)
    tick_marks = numpy.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)
    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
                 horizontalalignment="center",
                 color="white" if cm[i, j] > thresh else "black")
    plt.ylabel('True label')
    plt.xlabel('Predicted label')

class Net(nn.Module):

    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(35, 16)
        # linear layer (n_hidden -> hidden_2)
        self.fc2 = nn.Linear(16, 8)
        # linear layer (n_hidden -> 10)
        self.fc3 = nn.Linear(8, 6)
        # dropout layer (p=0.2)

        # dropout layer (p=0.2)
        # dropout prevents overfitting of data
        # self.dropout = nn.Dropout(0.2)

    def forward(self, x):
        # x = x.view(-1, 35)
        # add hidden layer, with relu activation function
        x = self.fc1(x)
        # x = self.dropout(x)
        x =self.fc2(x)
        # x = self.dropout(x)
        x = self.fc3(x)
        # x = self.dropout(x)
        return x


class GasPressureDataset(torch.utils.data.Dataset):

    def __init__(self, directory, num_csv):
        self.transform = ""
        self.directory = directory
        self.num_csv = num_csv
        self.arg_number_entries_per_label = 35
        self.numdata = numpy.zeros((1, self.arg_number_entries_per_label))
        self.numpressure = numpy.zeros((1, 1))

        for itr_csv in range(0, self.num_csv):
            filename = 'TrainingInputs%d.csv' % itr_csv
            raw_data = open(self.directory + filename, 'rt')
            reader = csv.reader(raw_data, delimiter=',', quoting=csv.QUOTE_NONE)
            reader_numpy = numpy.array(tuple(reader)).astype('float32')
            # reader_numpy = numpy.transpose(numpy.array(tuple(reader)).astype('float32'))
            self.numdata = numpy.delete(numpy.concatenate((self.numdata, reader_numpy)), 0, 0)
            numdata_x, numdata_y = reader_numpy.shape
            self.numpressure = numpy.delete(numpy.concatenate(
                (self.numpressure, numpy.full((numdata_x, 1), itr_csv))), 0, 0)  # -1 for zero entry
        # print(self.numdata.shape)
        # print(self.numgas.shape)
        # print(self.numpressure.shape)

    def __getitem__(self, idx):
        # if torch.is_tensor(idx):
        #     idx = idx.tolist()
        # sample = {'Gas': self.gas[idx], 'Pressure': idx, 'Data': self.data[idx]}
        pressure = torch.Tensor(self.numpressure[idx])
        data = torch.Tensor(self.numdata[idx])
        return pressure, data

    def __len__(self):
        return len(self.numdata)


class AmonniaOrNot:

    def __init__(self):
        # self.directory = '/home/kogami/workspace/InPhoSS-RA/Peak-detection/MatlabSim/Afterpeak/'
        self.directory = '/home/kogami/workspace/InPhoSS-RA/FFT/Matlab/'
        self.pwd = os.path.dirname(os.path.realpath(__file__))
        self.num_csv = 6
        self.num_csv_valid = 2
        self.num_csv_test = 1
        self.inputdata = numpy.zeros([1, 35])
        self.inputdatatest = numpy.zeros([1, 35])
        self.inputdatavalid = numpy.zeros([1, 35])
        self.batchsize = 1
        self.batches = 60
        self.epochs = 150
        self.valid_loss_min = numpy.Inf  # set initial "min" to infinity
        self.model = Net()
        self.criterion = nn.CrossEntropyLoss()  # specify optimizer (stochastic gradient descent) and learning rate = 0.01
        self.model.cuda()
        # self.model = torch.nn.DataParallel(self.model, device_ids=range(torch.cuda.device_count()))

    def create_dataset(self):

        dataset = GasPressureDataset(self.directory, self.num_csv)
        validation_split = .1
        shuffle_dataset = True
        random_seed = 42

        dataset_size = len(dataset)
        indices = list(range(dataset_size))
        split = int(numpy.floor(validation_split * dataset_size))
        if shuffle_dataset:
            numpy.random.seed(random_seed)
            numpy.random.shuffle(indices)
        train_test_indices, val_indices = indices[split:], indices[:split]

        test_split = .5
        testsplit = int(numpy.floor(test_split * dataset_size))
        if shuffle_dataset:
            numpy.random.seed(random_seed)
            numpy.random.shuffle(train_test_indices)
        train_indices, test_indices = train_test_indices[testsplit:], train_test_indices[:testsplit]
        train_sampler = torch.utils.data.SubsetRandomSampler(train_indices)
        valid_sampler = torch.utils.data.SubsetRandomSampler(val_indices)
        test_sampler = torch.utils.data.SubsetRandomSampler(test_indices)
        self.train_loader = torch.utils.data.DataLoader(dataset, batch_size=self.batchsize,
                                                        sampler=train_sampler, num_workers=0)
        self.validation_loader = torch.utils.data.DataLoader(dataset, batch_size=self.batchsize,
                                                             sampler=valid_sampler, num_workers=0)
        self.test_loader = torch.utils.data.DataLoader(dataset, batch_size=self.batchsize,
                                                       sampler=test_sampler, num_workers=0)

    def train(self):
        valid_running_loss = 0.0
        use_cuda = torch.cuda.is_available()
        device = torch.device("cuda:0" if use_cuda else "cpu")
        print(device)
        torch.backends.cudnn.benchmark = True
        self.model.to(device)
        # specify loss function (categorical cross-entropy)
        optimizer = torch.optim.SGD(self.model.parameters(), lr=0.00_0005)
        criterion = nn.CrossEntropyLoss()
        running_loss = 0
        graph_running_loss = 0
        loss_values = []
        valid_running_loss_values = []
        print(len(self.train_loader))
        # Loop over epochs
        for epoch in range(self.epochs):
            # Training
            # print(len(list(enumerate(self.train_loader))))
            self.model.train()
            for batch_idx, (local_pressure, local_batch) in enumerate(self.train_loader):
                # Transfer to GPU
                local_pressure, local_batch =  torch.tensor(
                    local_pressure.cuda()), torch.tensor(local_batch.cuda())
                optimizer.zero_grad()
                output = self.model(local_batch)
                # print("Output ")
                # print(output)
                # print("Local_pressure ")
                # print(local_pressure.flatten().to(device).long())
                loss = criterion(output, local_pressure.flatten().to(device).long())

                loss.backward()
                running_loss += loss.item() / self.batches
                graph_running_loss = running_loss
                # print statistics
                if batch_idx % self.batches == self.batches-1:
                    # print('Training [%d, %5d] loss: %.3f' %
                    #       (epoch + 1, batch_idx + 1, running_loss / self.batches))
                    running_loss = 0.0
                    # with torch.no_grad:
                if(epoch == self.epochs-1):
                    torch.save(self.model.state_dict(), 'model.pt')
                    pd.DataFrame(self.model.fc1.weight.detach().cpu().numpy()).to_csv('model_fc1_wts.dat', header=None, index=None, sep='\n')
                    pd.DataFrame(self.model.fc2.weight.detach().cpu().numpy()).to_csv('model_fc2_wts.dat', header=None, index=None, sep='\n')
                    pd.DataFrame(self.model.fc3.weight.detach().cpu().numpy()).to_csv('model_fc3_wts.dat', header=None, index=None, sep='\n')
                    pd.DataFrame(self.model.fc1.bias.detach().cpu().numpy()).to_csv('model_fc1_bias.dat', header=None, index=None, sep='\n')
                    pd.DataFrame(self.model.fc2.bias.detach().cpu().numpy()).to_csv('model_fc2_bias.dat', header=None, index=None, sep='\n')
                    pd.DataFrame(self.model.fc3.bias.detach().cpu().numpy()).to_csv('model_fc3_bias.dat', header=None, index=None, sep='\n')

                optimizer.step()
            self.model.eval()
            valid_running_loss = 0.0
            with torch.set_grad_enabled(False):
                for local_pressure, local_batch in self.validation_loader:
                    # Transfer to GPU
                    local_pressure, local_batch = local_pressure.to(
                        device), local_batch.to(device)
                    output = self.model(local_batch)
                    valid_loss = criterion(output, local_pressure.flatten().to(device).long())
                    valid_running_loss += valid_loss.item() /self.batches
                    # print('Validating [%d, %5d] loss: %.3f' %
                    #       (epoch + 1, batch_idx + 1, valid_running_loss / 2000))
                    # save model if validation loss has decreased
                    if valid_running_loss <= self.valid_loss_min:
                        # print('Validation loss decreased ({:.6f} --> {:.6f}).  Saving model ...'.format(
                        #     self.valid_loss_min,
                        #     valid_running_loss))
                        # torch.save(self.model.state_dict(), 'model.pt')
                        self.valid_loss_min = valid_running_loss
                valid_running_loss_values.append(-(valid_running_loss - 100))

            loss_values.append(-(graph_running_loss - 100))


        print('Finished training')
        f = plt.figure(1)
        plt.plot(loss_values, label = "Training accuracy")
        plt.plot(valid_running_loss_values, label="Validation accuracy")
        plt.legend(loc="lower right")
        plt.xlabel("Number of Batches")
        plt.ylabel("Accuracy (%)")
        plt.title("Training results for Pressure classification ")
        f.show()

        input()

    def test(self):
        self.model.load_state_dict(torch.load(self.pwd+'/model.pt'))
        use_cuda = torch.cuda.is_available()
        device = torch.device("cuda:0" if use_cuda else "cpu")
        # specify loss function (categorical cross-entropy)
        criterion = nn.CrossEntropyLoss()
        # initialize lists to monitor test loss and accuracy
        correct = 0
        test_loss = 0
        total = 0
        print(device)
        class_correct = list(0. for i in range(self.num_csv))
        class_total = list(0. for i in range(self.num_csv))
        self.model.eval()
        with torch.no_grad():
            for local_pressure, local_batch in self.test_loader:
                local_pressure, local_batch = local_pressure.to(
                    device), local_batch.to(device)
                outputs = self.model(local_batch)
                loss = criterion(outputs, local_pressure.flatten().to(device).long())
                test_loss += loss.item()
                _, pred = torch.max(outputs, 1)
                # compare predictions to true label
                correct = numpy.squeeze(pred.eq(local_pressure.data.view_as(pred)))
                # for i in range(len(target)):
                label = local_pressure.data
                # print(label.cpu().numpy().astype(int)[0].item(0))
                class_correct[label.cpu().numpy().astype(int)[0].item(0)] += correct.item()
                class_total[label.cpu().numpy().astype(int)[0].item(0)] += 1

        print('Test Loss: {:.6f}\n'.format(100-test_loss/len(self.test_loader)))
        for i in range(self.num_csv):
            if(class_total[i]) > 0:
                print('Test Accuracy of %5s: %2d%% (%2d/%2d)' % (
                    str(i), 100 * class_correct[i] / class_total[i],
                    numpy.sum(class_correct[i]), numpy.sum(class_total[i])))
            else:
                print('N/A (no training examples)')

        print('\nTest Accuracy (Overall): %2d%% (%2d/%2d)' % (
            100. * numpy.sum(class_correct) / numpy.sum(class_total),
            numpy.sum(class_correct), numpy.sum(class_total)))
    # Initialize the prediction and label lists(tensors)
        predlist = torch.zeros(0, dtype=torch.long, device='cpu')
        lbllist = torch.zeros(0, dtype=torch.long, device='cpu')
        use_cuda = torch.cuda.is_available()
        device = torch.device("cuda:0" if use_cuda else "cpu")
        with torch.no_grad():
            for i, (classes, inputs) in enumerate(self.test_loader):
                inputs = inputs.to(device)
                classes = classes.to(device)
                outputs = self.model(inputs)
                _, preds = torch.max(outputs, 1)

                # Append batch prediction results
                predlist = torch.cat([predlist, preds.view(-1).cpu()])
                lbllist = torch.cat([lbllist, classes.view(-1).cpu()])

        plot_classes = []
        for i in range(6):
            plot_classes.append(i)
        conf_mat = confusion_matrix(lbllist.numpy(), predlist.numpy())
        plot_confusion_matrix(conf_mat, plot_classes)
        plt.title("Confusion Matrix")
        plt.show()  # Per-class accuracy
        class_accuracy = 100 * conf_mat.diagonal() / conf_mat.sum(1)
        print(class_accuracy)



if __name__ == '__main__':
    classobj = AmonniaOrNot()
    classobj.create_dataset()
    # classobj.train()
    classobj.test()
