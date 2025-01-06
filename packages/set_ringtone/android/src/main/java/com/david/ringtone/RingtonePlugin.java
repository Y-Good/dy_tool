package com.david.ringtone;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.provider.Settings;
import android.webkit.MimeTypeMap;
import android.util.Log;
import android.os.Environment;
import android.database.Cursor;
import android.provider.OpenableColumns;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RingtonePlugin
 */
public class RingtonePlugin implements FlutterPlugin, MethodCallHandler {
    private static RingtonePlugin instance;
    private MethodChannel channel;
    private Context mContext;

    public static void registerWith(Registrar registrar) {
        if (instance == null) {
            instance = new RingtonePlugin();
        }
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    public void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        if (channel != null) {
            return;
        }
        this.mContext = applicationContext;

        channel = new MethodChannel(messenger, "ringtone_set");

        channel.setMethodCallHandler(this);
    }

    private boolean isSystemWritePermissionGranted() {
        boolean retVal = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            retVal = Settings.System.canWrite(mContext);
        }
        return retVal;
    }

    private void requestSystemWritePermission() {
        boolean retVal = isSystemWritePermissionGranted();
        if (!retVal) {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_WRITE_SETTINGS);
                String both = "package:" + mContext.getPackageName();
                intent.setData(Uri.parse(both));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mContext.startActivity(intent);
            }
        }
    }

    private static String guessMimeTypeFromExtension(String path) {
        String mimeType = null;
        String fileExtension = "";
        try {
            int i = path.lastIndexOf('.');
            if (i > 0) {
                fileExtension = path.substring(i + 1);
            }
            if (fileExtension != "") {
                mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension);
            }
        } catch (Exception ignored) {

        }

        return mimeType;
    }

    static private String guessMimeTypeFromStream(InputStream is) throws IOException {
        // If we can't read ahead safely, just give up on guessing
        if (!is.markSupported()) return null;

        is.mark(16);
        int c1 = is.read();
        int c2 = is.read();
        int c3 = is.read();
        int c4 = is.read();
        int c5 = is.read();
        int c6 = is.read();
        int c7 = is.read();
        int c8 = is.read();
        int c9 = is.read();
        int c10 = is.read();
        int c11 = is.read();
        is.reset();

        if (c1 == 0x2E && c2 == 0x73 && c3 == 0x6E && c4 == 0x64) {
            return "audio/basic";  // .au format, big endian
        }

        if (c1 == 0x64 && c2 == 0x6E && c3 == 0x73 && c4 == 0x2E) {
            return "audio/basic";  // .au format, little endian
        }

        if (c1 == 'R' && c2 == 'I' && c3 == 'F' && c4 == 'F') {
            return "audio/x-wav";
        }

        if (c1 == 0x23 && c2 == 0x21 && c3 == 0x41 && c4 == 0x4D && c5 == 0x52) {
            return "audio/amr";
        }

        if (c1 == 0x66 && c2 == 0x74 && c3 == 0x79 && c4 == 0x70 && c5 == 0x69 && c6 == 0x73 && c7 == 0x6F && c8 == 0x6D) {
            return "audio/mp4";
        }

        if (c1 == 0x00 && c2 == 0x00 && c3 == 0x00 && c4 == 0x20 && c5 == 0x66 && c6 == 0x74 && c7 == 0x79 && c8 == 0x70 && c9 == 0x4D && c10 == 0x34 && c11 == 0x41) {
            return "audio/mp4";
        }

        if (c1 == 0x4D && c2 == 54 && c3 == 68 && c4 == 64) {
            return "audio/midi";
        }

        if (c1 == 0x1A && c2 == 0x45 && c3 == 0xDF && c4 == 0xA3) {
            return "audio/x-matroska";
        }

        if (c1 == 0x30 && c2 == 0x26 && c3 == 0xB2 && c4 == 0x75 && c5 == 0x8E && c6 == 0x66 && c7 == 0xCF && c8 == 0x11) {
            return "audio/x-ms-wma";
        }

        if (c1 == 0x4F && c2 == 0x67 && c3 == 0x67 && c4 == 0x53) {
            return "audio/ogg";
        }

        if (c1 == 0x49 && c2 == 0x44 && c3 == 0x33) {
            return "audio/mpeg";
        }

        if (c1 == 0xFF && (c2 == 0xFB || c2 == 0xF3 || c2 == 0xF2)) {
            return "audio/mpeg";
        }

        return null;
    }

    private static String getMIMEType(String absolutePath) {
        String mimeType = null;
        mimeType = guessMimeTypeFromExtension(absolutePath);

        if (mimeType != null) {
            return mimeType;
        }

        try (InputStream inputStream = new BufferedInputStream(new FileInputStream(absolutePath))) {
            mimeType = guessMimeTypeFromStream(inputStream);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (mimeType != null) {
            return mimeType;
        }

        return "audio/mpeg";
    }

    private String getRingtone() {
        Uri uri = RingtoneManager.getActualDefaultRingtoneUri(mContext, RingtoneManager.TYPE_RINGTONE);
        return RingtoneManager.getRingtone(mContext, uri).getTitle(mContext);
    }

    public static void deleteFilesInDirectory(String fileName) {
        String filePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Ringtones/music/" + fileName;

        File file = new File(filePath);

        if (!file.exists()) {
            return;
        }
        file.delete();
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    private void setThings(String path) {
        requestSystemWritePermission();
        File mFile = new File(path);  // set File from path
        if (mFile.exists()) {
            // Android 10 or newer
            if (android.os.Build.VERSION.SDK_INT > 28) {// file.exists
                deleteFilesInDirectory(mFile.getName());
                ContentValues values = new ContentValues();
                values.put(MediaStore.Audio.Media.DISPLAY_NAME, mFile.getName());
                values.put(MediaStore.Audio.Media.MIME_TYPE, getMIMEType(mFile.getAbsolutePath()));
                values.put(MediaStore.Audio.Media.TITLE, mFile.getName());
                values.put(MediaStore.Audio.Media.RELATIVE_PATH, "Ringtones/music");
                values.put(MediaStore.Audio.Media.IS_RINGTONE, true);
                values.put(MediaStore.Audio.Media.IS_NOTIFICATION, false);
                values.put(MediaStore.Audio.Media.IS_ALARM, false);
                values.put(MediaStore.Audio.Media.IS_MUSIC, false);

                Uri insertUri = mContext.getContentResolver().insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, values);

                OutputStream os = null;
                FileInputStream inputStream = null;


                if (insertUri != null) {
                    try {
                        os = mContext.getContentResolver().openOutputStream(insertUri);
                        if (os != null) {
                            inputStream = new FileInputStream(mFile);
                            byte[] bytes = new byte[1024];
                            int len;
                            while ((len = inputStream.read(bytes)) != -1) {
                                os.write(bytes, 0, len);
                            }
                            inputStream.close();
                            os.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                }
                RingtoneManager.setActualDefaultRingtoneUri(mContext, RingtoneManager.TYPE_RINGTONE, insertUri);
            } else {
                // Android 9 or older
                final String absolutePath = mFile.getAbsolutePath();

                ContentValues values = new ContentValues();
                values.put(MediaStore.MediaColumns.DATA, absolutePath);
                values.put(MediaStore.MediaColumns.TITLE, "Custom ringtone");
                values.put(MediaStore.MediaColumns.SIZE, mFile.length());
                values.put(MediaStore.Audio.Media.ARTIST, "Ringtone app");
                values.put(MediaStore.Audio.Media.IS_RINGTONE, true);
                values.put(MediaStore.Audio.Media.IS_NOTIFICATION, false);
                values.put(MediaStore.Audio.Media.IS_ALARM, false);
                values.put(MediaStore.Audio.Media.IS_MUSIC, false);

                // insert it into the database
                Uri uri = MediaStore.Audio.Media.getContentUriForPath(absolutePath);

                // delete the old one first
                mContext.getContentResolver().delete(uri, MediaStore.MediaColumns.DATA + "=\"" + absolutePath + "\"", null);

                // insert a new record
                Uri newUri = mContext.getContentResolver().insert(uri, values);

                RingtoneManager.setActualDefaultRingtoneUri(mContext, RingtoneManager.TYPE_RINGTONE, newUri);
            }
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("setRingtone")) {
            String path = call.argument("path");
            setThings(path);
            result.success(true);
        } else if (call.method.equals("isWriteGranted")) {
            boolean granted = isSystemWritePermissionGranted();
            result.success(granted);
        } else if (call.method.equals("getRingtone")) {
//            Uri ringtone = getRingtone();
            result.success(getRingtone());
        } else if (call.method.equals("deleteRingtone")) {
            deleteFilesInDirectory(call.argument("fileName"));
        } else {
            result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
