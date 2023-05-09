#!/bin/sh

# Clean up
yum --obsoletes update

# Clear history
history -c

# Remove temporary files
rm -rf /tmp/*