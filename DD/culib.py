#!/usr/bin/env python3
import configparser
import numpy as np
import numpy.ctypeslib as npct
import ctypes
from ctypes import c_int
from ctypes import c_float
import time
from matplotlib import pyplot as plt
import math
from progressbar import *

def decodeconf(path):
    conf=configparser.ConfigParser()
    conf.read(path)
    reslist=[]
    selist=conf.sections()
    for dog in selist:
        reslist+=conf.items(dog)
    dic=dict(reslist)
    return dic

class caldog(object):
    def __init__(self, dic):
        conf=dic
        initz0 = conf['z0路径']
        self.z0=np.load(initz0)
        self.m=float(conf['m'])
        conf=dic
        self.outf=conf["输出频率"]
        self.N=conf['计算时间']
        self.outpath=conf['输出路径']

        if self.z0.dtype == 'float32':
            print("OK")
        if conf['自动初值']=='是' or conf['自动初值']=='y' or conf['自动初值']=='y':
            print('开始自动生成')
            self.p0=np.zeros(np.shape(self.z0),dtype='float32')
            self.vx=np.zeros(np.shape(self.z0),dtype='float32')
            self.vz=np.zeros(np.shape(self.z0),dtype='float32')
            print('自动生成成功')
        else:
            initp0=conf['p0路径']
            self.p0=np.load(initp0)
            if self.z0.dtype == 'float32':
                print(str(initp0)+'导入成功')
            else:
                print("警告:数据类型错误。")
                    
            initvx=conf['vx路径']
            self.vx=np.load(initvx)
            if self.vx.dtype == 'float32':
                print(str(initvx)+'导入成功')
            else:
                print("警告:数据类型错误。")
            initvz=conf['vz路径']
            self.vz=np.load(initvz)
            if self.vz.dtype == 'float32':
                print(str(initvz)+'导入成功')
            else:
                print("警告:数据类型错误。")
        self.ff=np.array(self.p0.strides,dtype='int32')
        self.dd=np.array(np.shape(self.p0),dtype='int32')
        pass

    def loadlib(self,libp):
        
        self.libcd = npct.load_library("calkel2", ".")
        array_1d_double = npct.ndpointer(dtype=np.float32, ndim=2, flags='CONTIGUOUS')
        self.libcd.cal.argtypes=[array_1d_double,array_1d_double,array_1d_double,array_1d_double,c_int,c_int,c_int,c_int,c_int,c_int,c_float,c_int]
        self.libcd.cal.restype=c_int
        pass
    def calcal(self,start,end):
        self.libcd.cal(self.p0,self.vx,self.vz,self.z0,self.ff[1],self.ff[0],self.dd[1],self.dd[0],start,end,self.m,0)
        pass

    def cal(self):
        a=int(int(self.N)/int(self.outf))
        b=int(self.N)%int(self.outf)
        c=0
        pbar = ProgressBar()
        for numtime in pbar(range(0,a)):
            self.calcal(c,c+a)
            np.save(str(self.outpath)+'p0_'+str(numtime),self.p0)
            np.save(str(self.outpath)+'vx_'+str(numtime),self.vx)
            np.save(str(self.outpath)+'vz_'+str(numtime),self.vz)
            c=c+a
            pass
        self.calcal(c,c+b)
        np.save(self.outpath+'p0_'+str(a),self.p0)
        np.save(self.outpath+'vx_'+str(a),self.vx)
        np.save(self.outpath+'vz_'+str(a),self.vz)
        pass
    
    pass