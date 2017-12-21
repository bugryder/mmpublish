#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright © 2014 kugou.com
# Author: Zhongxin Huang <huangzhongxin@kugou.net>
#
# 将版本号排序
# shell算法太慢，用python来实现
#

import sys
import os
from distutils.version import LooseVersion


def version_compare(v1, v2):
    ''' version compare
    Args:
      v1, v2: Two strings of version, for example:
      '2.0', '3.0'

    Returns:
      string. for example:
      v1 is less than v2, return '<'
      v1 is equal to v2, return '='
      v1 is greater then v2, return '>'
    '''
    v1 = str(v1.lower())
    v2 = str(v2.lower())
    
    for x in ['gray_', 'rel_', 'V', 'v', 'release_']:
        v1 = v1.replace(x, '');
        v2 = v2.replace(x, '');
    
    _cmp = lambda x, y: LooseVersion(x).__cmp__(y)
    ret = _cmp(v1, v2)
    if ret == 1:
        return '>'
    if ret == -1:
        return '<'
    return '='


def version_order(type, versions):
    '''
    Args:
        type: string
        versions: list

    Returns:
        list
    '''
    type = str(type.lower())
    len_ver = len(versions)
    for i in range(1, len_ver):
        sublen = len_ver - i
        for k in range(0, sublen):
            next = k + 1
            if type == 'asc':
                if version_compare(versions[k], versions[next]) == '>':
                    tmp = versions[next];
                    versions[next] = versions[k];
                    versions[k] = tmp
            if type == 'desc':
                if version_compare(versions[k], versions[next]) == '<':
                    tmp = versions[next];
                    versions[next] = versions[k];
                    versions[k] = tmp
    
    return [x for x in versions]


def main():
    argvs = sys.argv[1:]
    if argvs:
        for x in version_order(argvs[0], argvs[1:]):
            print x


if __name__ == '__main__':
    main()
