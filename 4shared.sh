#!/bin/bash
#
# This file is part of Plowshare.
#
# Plowshare is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Plowshare is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Plowshare.  If not, see <http://www.gnu.org/licenses/>.
#
MODULE_4SHARED_REGEXP_URL="http://\(www\.\)\?4shared.com/file/"
MODULE_4SHARED_DOWNLOAD_OPTIONS=""
MODULE_4SHARED_UPLOAD_OPTIONS=
MODULE_4SHARED_DOWNLOAD_CONTINUE=no

# Output a 4shared file download URL
#
# $1: A 4shared URL
#
4shared_download() {
    set -e
    eval "$(process_options 4shared "$MODULE_4SHARED_DOWNLOAD_OPTIONS" "$@")"

    URL=$1
    WAIT_URL=$(curl "$URL" | parse "4shared.com\/get\/" 'href="\([^"]*\)"') ||
        { error "file not found"; return 254; }
    WAIT_HTML=$(curl "$WAIT_URL")

    test "$CHECK_LINK" && return 255

    WAIT_TIME=$(echo "$WAIT_HTML" | parse "id='downloadDelayTimeSec'" \
        ">\([[:digit:]]\+\)<")
    FILE_URL=$(echo "$WAIT_HTML" | parse "\.4shared\.com\/download\/" \
        "href='\([^']*\)'")

    # Try to figure out real name written on page
    FILE_REAL_NAME=$(echo $WAIT_HTML | parse '<b class="xlarge blue">' \
                    'blue">\([^<]\+\)' 2>/dev/null)

    countdown $((WAIT_TIME)) 5 seconds 1 || return 2

    echo "$FILE_URL"
    test -n "$FILE_REAL_NAME" && echo "$FILE_REAL_NAME"
    return 0
}
