"""weight init"""
import math
import numpy as np
from mindspore import Tensor, Parameter

def gru_default_state(batch_size, input_size, hidden_size, num_layers=1, bidirectional=False):
    '''Weight init for gru cell'''
    stdv = 1 / math.sqrt(hidden_size)
    weight_i = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (input_size, 3*hidden_size)).astype(np.float16)), name='weight_i')
    weight_h = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (hidden_size, 3*hidden_size)).astype(np.float16)), name='weight_h')
    bias_i = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (3*hidden_size)).astype(np.float16)), name='bias_i')
    bias_h = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (3*hidden_size)).astype(np.float16)), name='bias_h')
    init_h = Tensor(np.zeros((batch_size, hidden_size)).astype(np.float16))
    return weight_i, weight_h, bias_i, bias_h, init_h

def gru_default_state_bw(batch_size, input_size, hidden_size, num_layers=1, bidirectional=False):
    '''Weight init for gru cell'''
    stdv = 1 / math.sqrt(hidden_size)
    weight_bw_i = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (input_size, 3*hidden_size)).astype(np.float16)), name='weight_bw_i')
    weight_bw_h = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (hidden_size, 3*hidden_size)).astype(np.float16)), name='weight_bw_h')
    bias_bw_i = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (3*hidden_size)).astype(np.float16)), name='bias_bw_i')
    bias_bw_h = Parameter(Tensor(
        np.random.uniform(-stdv, stdv, (3*hidden_size)).astype(np.float16)), name='bias_bw_h')
    init_bw_h = Tensor(np.zeros((batch_size, hidden_size)).astype(np.float16))
    return weight_bw_i, weight_bw_h, bias_bw_i, bias_bw_h, init_bw_h

def dense_default_state(in_channel, out_channel):
    '''Weight init for dense cell'''
    stdv = 1 / math.sqrt(in_channel)
    weight = Tensor(np.random.uniform(-stdv, stdv, (out_channel, in_channel)).astype(np.float32))
    bias = Tensor(np.random.uniform(-stdv, stdv, (out_channel)).astype(np.float32))
    return weight, bias
