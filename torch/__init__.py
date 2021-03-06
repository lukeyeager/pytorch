import torch.C

class FloatTensor(C.FloatTensorBase):
    def __str__(self):
        return "Tensor"

    def __repr__(self):
        return str(self)

class LongStorage(C.LongStorageBase):
    def __str__(self):
        content = ' ' + '\n '.join(str(self[i]) for i in range(len(self)))
        return content + '\n[torch.LongStorage of size {}]'.format(len(self))

    def __repr__(self):
        return str(self)
