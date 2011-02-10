#!/usr/bin/env python

from optparse import OptionParser
import commands
import os
import re
import sys

PROJECT = "Linkstr"
PROJ_APP = PROJECT + ".app"
DEST_DIR = os.environ["HOME"] + "/Applications/Util"
BUILD_DIR = os.environ["PWD"] + "/build/Release"
STAGE_DIR = os.environ["HOME"] + "/Sites/" + PROJECT
SCP_TARGET = "linkstr.net:linkstr.net"
SVN_REPO = "http://linkstr.net/svn/Linkstr"

parser = OptionParser()
parser.add_option("-l", "--local", action="store_true", dest="local")
parser.add_option("-t", "--type", dest="type", default="build")
parser.add_option("-v", "--verbose", dest="verbose", action="store_true")
parser.add_option("-d", "--destination", dest="dest", default=DEST_DIR)
parser.add_option("-b", "--build_dir", dest="build", default=BUILD_DIR)
parser.add_option("-s", "--stage_dir", dest="stage", default=STAGE_DIR)
parser.add_option("-c", "--scp_target", dest="scp", default=SCP_TARGET)

(options, args) = parser.parse_args(sys.argv)

def run(cmd, *opts):
    if opts:
        cmd = cmd % opts
    sys.stderr.write(cmd + "\n")
    (ret, out) = commands.getstatusoutput(cmd)
    if options.verbose:
        sys.stderr.write(out + "\n")
    if ret:
        print "Error: %d" % (ret,)
        sys.exit(1)
    return out
    
VERFILE = "Version.xcconfig"

ver = open(VERFILE, "r")
ver_m = re.search("APP_VERSION=([0-9]+)", ver.readline())
BUILD = int(ver_m.group(1))

disp_m = re.search("APP_VERSION_DISPLAY=([0-9]+)\.([0-9]+)", ver.readline())
MAJ = int(disp_m.group(1))
MIN = int(disp_m.group(2))
ver.close()

BUILD += 1
if options.type == "minor":
    MIN += 1
elif options.type == "major":
    MAJ += 1
elif options.type == "none":
    pass
else:
    print "Valid types: build | minor | major"
    sys.exit(64)
    
ver = open(VERFILE, "w")
ver.write("APP_VERSION=%d\n" % (BUILD,))
ver.write("APP_VERSION_DISPLAY=%d.%d\n" % (MAJ, MIN))
ver.close()

#run("svn ci -m 'Releasing build %d' %s", BUILD, VERFILE)
run("git add %s", VERFILE)
run("git ci -m 'Releasing build %d' %s", BUILD, VERFILE)

#run("svn copy . file:///var/svn/Linkstr/tags/%s-%d -m 'Releasing build %d'",
#    PROJECT, BUILD, BUILD)
run("git tag -a -m 'Releasing build %d' %s-%d", BUILD, PROJECT, BUILD)
run("git push --tags origin master")

print "Building %d.%d.%d" % (MAJ, MIN, BUILD)
run("xcodebuild -configuration Release clean")
run("xcodebuild -configuration Release")
run("rm -rf %s/%s", options.dest, PROJ_APP)
run("cp -R %s/%s %s", options.build, PROJ_APP, options.dest)
if options.local:
    sys.exit(0)

ZIP = "%s_%d.zip" % (PROJECT, BUILD)
os.chdir(BUILD_DIR)
date = run("date -Ru")
run("zip -q -r %s %s", ZIP, PROJ_APP)
md5 = run("md5sum %s | awk '{print $1}'", ZIP)
size = run("du -b %s | awk '{print $1}'", ZIP)

changes = open("changes.xml", "w")
changes.write("""
<?xml version='1.0' encoding='utf-8'?> 
<rss version='2.0' 
     xmlns:dc='http://purl.org/dc/elements/1.1/'
     xmlns:sparkle='http://www.andymatuschak.org/xml-namespaces/sparkle'> 
  <channel> 
    <title>%s Changelog</title> 
    <link>http://linkstr.net/changes.xml</link> 
    <description>Most recent changes with links to updates.</description> 
    <language>en</language> 
    <item> 
      <title>Version %d.%d.%d</title> 
      <description>http://linkstr.net/Last_Changes.html</description> 
      <pubDate>%s</pubDate> 
      <enclosure url='http://linkstr.net/%s'
                 sparkle:shortVersionString='%d.%d.%d'
                 sparkle:version='%d'
                 sparkle:md5Sum='%s'
                 length='%s'
                 type='application/octet-stream'/>
    </item>
  </channel>
</rss>
""" % (PROJECT, MAJ, MIN, BUILD, date, ZIP, MAJ, MIN, BUILD, BUILD, md5, size))
changes.close()
run("mv changes.xml %s", options.stage)
run("mv %s %s", ZIP, options.stage)
os.chdir(options.stage)
#run("scp %s changes.xml %s", ZIP, options.scp)
#run("ssh linkstr.net 'cd linkstr.net; rm latest.zip; ln -s %s latest.zip'", ZIP)
