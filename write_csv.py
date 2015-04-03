from __future__ import print_function
import io
import plistlib
import shutil

orig_xml = 'C:\\Users\\ccvector\\Music\\iTunes\\iTunes Music Library.xml'
shutil.copy(orig_xml, 'library.xml')
xml = plistlib.readPlist('library.xml')
keys = [
    'Album', 'Persistent ID', 'Track Number', 'Location',
    'File Folder Count', 'Album Rating Computed', 'Total Time',
    'Sample Rate', 'Genre', 'Bit Rate', 'Kind', 'Name', 'Artist',
    'Date Added', 'Album Rating', 'Artwork Count', 'Rating',
    'Date Modified', 'Library Folder Count', 'Year', 'Track ID',
    'Size', 'Track Type', 'Play Count', 'Play Date', 'Play Date UTC'
]
rows = [','.join([k.lower().replace(' ', '_') for k in keys])]
for track in xml['Tracks'].values():
    row = []
    for key in keys:
        try:
            value = unicode(track[key]).replace(',', ';')
        except KeyError:
            value = 'NA'
        row.append(value)
    rows.append(','.join(row))
with io.open('database.csv', 'w', encoding='utf8') as doc:
    doc.write('\n'.join(rows))
