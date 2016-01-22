#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#			http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
from file_storage import upload_file_and_get_url
import json
import urllib2
from google.appengine.api import images

class MainHandler(webapp2.RequestHandler):
		def get(self):
				self.response.write('Hello world!')

class RawUploadHandler(webapp2.RequestHandler):
	def post(self):
		content_type = self.request.get('content-type')
		data = self.request.body
		url = upload_file_and_get_url(self.request.body, mimetype=self.request.get('content-type'))
		self.response.headers['Content-Type'] = 'application/json'
		self.response.write(json.dumps({"url": url}))

class UploadHandler(webapp2.RequestHandler):
	def post(self):
		self.response.headers.add_header('Access-Control-Allow-Origin', '*')
		self.response.headers['Content-Type'] = 'application/json'
		file = self.request.POST['file']
		url = upload_file_and_get_url(file.value, mimetype=file.type)
		self.response.write(json.dumps({"url": url, "mimeType": file.type, "filename": file.filename}))
	
	def options(self):			
			self.response.headers['Access-Control-Allow-Origin'] = '*'
			self.response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Cache-Control'
			self.response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE'

class MirrorHandler(webapp2.RequestHandler):
	def get(self):
		# allow cross-origin use:
		self.response.headers.add_header('Access-Control-Allow-Origin', '*')
		self.response.headers.add_header('Cache-Control', 'max-age=604800')
		url = self.request.get('url')
		response = urllib2.urlopen(url)
		original_headers = {}
		for header in response.info().headers:
			key, val = header.split(':', 1)
			original_headers[key.lower()] = val.strip()
		content_type = original_headers.get('content-type', 'application/octet-stream')
		data = response.read()
		
		def sanitize_filename(filename):
			chars = 'abcdefghijklmnopqrstuvwxyz0123456789-_.,'
			return ''.join([c for c in filename if c in chars])
		
		force_download_with_filename = self.request.get('force_download_with_filename')
		if force_download_with_filename:
			self.response.headers.add_header('Content-Disposition', str('attachment; filename=' + sanitize_filename(force_download_with_filename)))
		
		resize = self.request.get('resize')
		if resize:
			w,h = map(float, resize.split(','))
			img = images.Image(data)
			ow, oh = img.width, img.height
			scale = min(w/ow, h/oh, 1)
			img.resize(int(ow*scale), int(oh*scale))
			if content_type == 'image/jpeg':
				output_encoding = images.JPEG
			else:
				output_encoding = images.PNG
				content_type = 'image/png'
			data = img.execute_transforms(output_encoding=output_encoding)
		
		self.response.headers['Content-Type'] = content_type
		self.response.write(data)

app = webapp2.WSGIApplication([
		('/', MainHandler),
		('/upload', UploadHandler),
		('/raw_upload', RawUploadHandler),
		('/mirror', MirrorHandler)
], debug=True)
