#!/bin/sh

# Decrypt the file
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output /home/runner/work/moojik/moojik/key.jks /home/runner/work/moojik/moojik/key.jks.gpg

