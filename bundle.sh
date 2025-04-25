#!/bin/bash
BUNDLE_PATH="--bundles--"
mkdir -p $BUNDLE_PATH
mkdir -p .bundle
cd .bundle
echo "|-- Total.js bundle compiler"
echo "| |-- app.bundle"
time_start=$(date +%s.%N)

# Copy directories for main bundle
cp -a ../controllers/ controllers
cp -a ../definitions/ definitions
cp -a ../modules/ modules
cp -a ../public/ public
cp -a ../schemas/ schemas
cp -a ../views/ views
cp -a ../resources/ resources

# Only create the plugins directory (no contents) for the main bundle
mkdir -p plugins

# Bundle main app (with empty plugins directory)
total5 bundle app.bundle
cp app.bundle ../$BUNDLE_PATH/app.bundle

# Build plugin bundles
echo "| |-- Building plugin bundles"
if [ -d "../plugins" ]; then
  for plugin_dir in ../plugins/*; do
    if [ -d "$plugin_dir" ]; then
      plugin_name=$(basename "$plugin_dir")
      echo "| |-- $plugin_name.bundle"
      
      # Create a clean directory structure
      rm -rf temp_plugin_bundle
      mkdir -p temp_plugin_bundle/plugins/$plugin_name
      
      # Copy all the plugin's content
      cp -a $plugin_dir/* temp_plugin_bundle/plugins/$plugin_name/
      
      # Create the bundle from the temp directory
      cd temp_plugin_bundle
      total5 bundle $plugin_name.bundle .
      cp $plugin_name.bundle ../../$BUNDLE_PATH/
      cd ..
      
      # Clean up
      rm -rf temp_plugin_bundle
    fi
  done
fi

# Return to parent directory and cleanup
cd ..
rm -rf .bundle

# Calculate and display execution time
time_end=$(date +%s.%N)
execution_time=$(echo "$time_end - $time_start" | bc)
echo "|-- Compilation: ${execution_time}s"