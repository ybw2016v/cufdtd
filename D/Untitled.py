
# coding: utf-8

# In[1]:


import numpy as np
import numpy.ctypeslib as npct
import ctypes
from ctypes import c_int
import math
from matplotlib import pyplot as plt


# In[2]:


libcd = npct.load_library("cone", ".")


# In[3]:


ssx=10
ssy=40


# In[4]:


array_1d_double = npct.ndpointer(dtype=np.float32, ndim=2, flags='CONTIGUOUS')
array_1d_double2 = npct.ndpointer(dtype=np.float32, ndim=2, flags='CONTIGUOUS')


# In[46]:


Datdog=np.zeros([ssx,ssy],dtype=np.float32)
canshu=np.ones([1,ssy],dtype=np.float32)*0.005


# In[23]:


intyoe=npct.ndpointer(dtype=c_int,ndim=1,flags='CONTIGUOUS')


# In[24]:


libcd.calkinit.restype = c_int


# In[25]:


libcd.calkinit.argtypes=[array_1d_double,array_1d_double2,intyoe,intyoe]


# In[26]:


libcd.cal.argtypes=[c_int]


# In[27]:


ff=np.array(Datdog.strides,dtype='int32')
dd=np.array(np.shape(Datdog),dtype='int32')


# In[28]:


# ff


# In[29]:


# dd


# In[30]:


libcd.calkinit(Datdog,canshu,ff,dd)


# In[31]:


# np.max(Datdog)


# In[32]:


pl=1#波源位置
ow=2#频率


# In[50]:


for lo in range(0,35):
    if lo>=2:
    
        Datdog[5,lo]=np.float16((5*math.sin(lo/6*ow*math.pi)))
        libcd.cal(np.array(lo,dtype=c_int))
    else:
        Datdog[5,lo]=np.float16((5*math.sin(lo/6*ow*math.pi)))


# In[51]:
print(Datdog)

plt.imshow(Datdog)
plt.colorbar()
plt.show()

# In[39]:


# libcd.cal(9)


# In[53]:




