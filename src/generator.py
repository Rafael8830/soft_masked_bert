from utils import load_json
import numpy as np

class CscDatasetGenerator:
    def __init__(self, fp):
        self.data = load_json(fp)

    def __len__(self):
        return len(self.data)

    def __getitem__(self, index):
        original_text = self.data[index]['original_text']
        original_text_np = np.array(original_text)
        res = (original_text_np)
        return res
