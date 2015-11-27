#!/bin/bash
bundle exec rake lint
puppet parser validate manifests
puppet parser validate --parser future manifests

