#flutter build ipa --build-name="$VERSION_NAME" --build-number=$VERSION_CODE --export-options-plist=ios/Params/ExportOptionsAdHoc.plist -t lib/$ENTRYPOINT --flavor=$FLAVOR
flutter build ipa --target=lib/main_prod.dart --flavor=prod --export-options-plist=ios/Params/ExportOptionsProd.plist --build-name="1.0" --build-number=2