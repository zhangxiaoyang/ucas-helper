#!/usr/bin/env python
# encoding: utf-8

import sys
import re

def mycourses():
    html = sys.stdin.read()
    rows = re.findall(r'(?s)<tr.*?>(.*?)</tr>', html)
    for index, row in enumerate(rows):
        if index <= 1:
            continue
        items = re.findall(r'(?s)<td.*?>(.*?)</td>', row)
        course = {}
        course['num'], course['id'], course['name'], course['score'], course['xuewei'], course['time'] = [i.strip() for i in items]
        course['name'] = course['name'].replace('（', '(').split('(')[0]
        course['xuewei'] = '1' if course['xuewei'] == '是' else '0'
        course['score'] = re.sub(r'<.*?>', '', course['score'])
        course['time'] = course['time'].split(')')[0] + ')'
        print '\t'.join([c[1] for c in course.iteritems()])

def checkbox(course_id):
    html = sys.stdin.read()
    rows = re.findall(r'(?s)<tr.*?>(.*?)</tr>', html)
    for index, row in enumerate(rows):
        try:
            items = re.findall(r'(?s)<td.*?>(.*?)</td>', row)
            ckb_id = re.sub(r'.*value="', '', items[0]).replace('" />', '').strip()
            c_id = items[1].strip()
            if course_id == c_id or course_id + 'Y/Z' == c_id:
                print ckb_id
                return
        except:
            pass
    print 'None'

if __name__ == '__main__':
    if sys.argv[1] == 'mycourses':
        mycourses()
        sys.exit(0)
    if sys.argv[1] == 'checkbox':
        checkbox(sys.argv[2])
        sys.exit(0)
    sys.exit(1)
