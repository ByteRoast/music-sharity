#!/bin/bash
# Music Sharity - Share music across all platforms
# Copyright (C) 2026 Sikelio (Byte Roast)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
set -e

if [ "$1" = "configure" ]; then
    echo ""
    echo "==================================================================="
    echo "  Music Sharity - Share music across all platforms"
    echo "==================================================================="
    echo ""
    echo "This software is licensed under the GNU General Public License v3."
    echo "You can view the full license at:"
    echo "  /usr/share/doc/music-sharity/copyright"
    echo ""
    echo "Or online at: https://www.gnu.org/licenses/gpl-3.0.html"
    echo ""
    echo "Thank you for installing Music Sharity!"
    echo "==================================================================="
    echo ""
fi

exit 0
