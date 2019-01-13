title: 'android:数据存储SharedPrefernces'
author: Kieran zhi
tags:
  - java
categories:
  - android
date: 2017-06-22 16:51:00
---
# Android 四大组件之使用SharedPrefernces

## SharedPreferences到底是什么

它是一个轻量级的存储类，特别适合用于保存软件配置参数。使用SharedPreferences保存数据，其背后是用xml文件存放数据，文件存放在/data/data/packagename/shared_prefs目录下：

<!-- more -->

## SharedPreferences使用

```
SharedPreferences sharedPreferences = getSharedPreferences("testshare", Context.MODE_PRIVATE);
Editor editor = sharedPreferences.edit();//获取编辑器
editor.putString("name", "kieran");
editor.putBoolean("isboy", true);
editor.commit();//提交修改
```
生成的testshare.xml文件内容如下：

```
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
<string name="name">kieran</string>
<boolean name="sex">true</boolean>
</map>
```

生成的文件路径

`/data/data/packagename/shared_prefs/testshare.xml`

## SharedPreferences获取

### 一、 getSharedPreferences(String name, int mode)

     abstract SharedPreferences	getSharedPreferences(String name, int mode)

1. name为本组件的配置文件名( 自己定义，也就是一个文件名，不需要带后缀名，系统自己添加)，当这个文件不存在时，直接创建，如果已经存在，则直接使用，
2. mode为操作模式，默认的模式为0或MODE_PRIVATE，还可以使用MODE_WORLD_READABLE和MODE_WORLD_WRITEABLE
> mode指定为MODE_PRIVATE，则该配置文件只能被自己的应用程序访问。
> mode指定为MODE_WORLD_READABLE，则该配置文件除了自己访问外还可以被其它应该程序读取。
> mode指定为MODE_WORLD_WRITEABLE，则该配置文件除了自己访问外还可以被其它应该程序读取和写入


### 二、PreferenceManager的方法getSharedPreferences()

* 可以通过查看其源码

```(java)
/** 
 * Gets a SharedPreferences instance that preferences managed by this will 
 * use. 
 *  
 * @return A SharedPreferences instance pointing to the file that contains 
 *         the values of preferences that are managed by this. 
 */  
public SharedPreferences getSharedPreferences() {  
    if (mSharedPreferences == null) {  
           mSharedPreferences = mContext.getSharedPreferences(mSharedPreferencesName,  
                   mSharedPreferencesMode);  
   }  
       return mSharedPreferences;  
}  
```
```
/**
 * Gets a SharedPreferences instance that preferences managed by this will
 * use.
 * @return A SharedPreferences instance pointing to the file that contains
 *         the values of preferences that are managed by this.
 */
public SharedPreferences getSharedPreferences() {
    if (mSharedPreferences == null) {
        mSharedPreferences = mContext.getSharedPreferences(mSharedPreferencesName,
                    mSharedPreferencesMode);
    }
    return mSharedPreferences;
}
```
* 其构造方法

```
/**
 * This constructor should ONLY be used when getting default values from
 * an XML preference hierarchy.
 * <p>
 * The {@link PreferenceManager#PreferenceManager(Activity)}
 * should be used ANY time a preference will be displayed, since some preference
 * types need an Activity for managed queries.
 */
private PreferenceManager(Context context) {
    init(context);
}

private void init(Context context) {
    mContext = context;
    setSharedPreferencesName(getDefaultSharedPreferencesName(context));
}

/**
 * Sets the name of the SharedPreferences file that preferences managed by this
 * will use.
 * 
 * @param sharedPreferencesName The name of the SharedPreferences file.
 * @see Context#getSharedPreferences(String, int)
 */
public void setSharedPreferencesName(String sharedPreferencesName) {
    mSharedPreferencesName = sharedPreferencesName;
    mSharedPreferences = null;
}

private static String getDefaultSharedPreferencesName(Context context) {
    return context.getPackageName() + "_preferences";
}
```
由以上方法，我们可以知道，最终我们调用getSharedPreferences()方法得到的是一个名为”yourpackageName_preferences“的偏好。同时其mode为默认私有。

### 三、getDefaultSharedPreferences方法
```
/**
 * Gets a SharedPreferences instance that points to the default file that is
 * used by the preference framework in the given context.
 * 
 * @param context The context of the preferences whose values are wanted.
 * @return A SharedPreferences instance that can be used to retrieve and
 *         listen to values of the preferences.
 */
public static SharedPreferences getDefaultSharedPreferences(Context context) {
    return context.getSharedPreferences(getDefaultSharedPreferencesName(context),
            getDefaultSharedPreferencesMode());
}
```

```
/**
 * Returns the name used for storing default shared preferences.
 *
 * @see #getDefaultSharedPreferences(Context)
 * @see Context#getSharedPreferencesPath(String)
 */
public static String getDefaultSharedPreferencesName(Context context) {
    return context.getPackageName() + "_preferences";
}

private static int getDefaultSharedPreferencesMode() {
    return Context.MODE_PRIVATE;
}
```

这个方法是静态的，因此可以直接调用，同时它与我们调用getSharedPreferences()方法得到的返回值是一样的，只是调用的方式不同罢了。


###  四、 getPreferences(mode) 方法
```
/**
 * Retrieve a {@link SharedPreferences} object for accessing preferences
 * that are private to this activity.  This simply calls the underlying
 * {@link #getSharedPreferences(String, int)} method by passing in this activity's
 * class name as the preferences name.
 *
 * @param mode Operating mode.  Use {@link #MODE_PRIVATE} for the default
 *             operation.
 *
 * @return Returns the single SharedPreferences instance that can be used
 *         to retrieve and modify the preference values.
 */
public SharedPreferences getPreferences(int mode) {
    return getSharedPreferences(getLocalClassName(), mode);
}
```
这个方法默认使用当前类类名作为文件的名称(不含包名)

## SharedPreferences 总结

> SharedPreferences 存取数据使用的是xml 文件，系统对xml 文件进行了加载优化，当然也可以使用自定义其他方式的文件存取。

如果想让其他应用能够读写，可以指定Modle权限。
```
MODE_WORLD_READABLE
MODE_WORLD_WRITEABLE
```

#### 访问其他应用中的Preference（使用的应用 preference创建时指定了Context.MODE_WORLD_READABLE或者Context.MODE_WORLD_WRITEABLE ）

1. 根据此应用的包名 创建Content
2. 通过创建Content访问preference ，访问preference时会在应用所在包下的shared_prefs目录找到preference

```
Context otherAppsContext = createPackageContext("cn.kieran.action", Context.CONTEXT_IGNORE_SECURITY);
SharedPreferences sharedPreferences = otherAppsContext.getSharedPreferences("testshare", Context.MODE_WORLD_READABLE);
String name = sharedPreferences.getString("name", "");
int age = sharedPreferences.getBoolean("isboy", "");
```

如果不通过创建Context访问其他应用的preference，也可以以读取xml文件方式直接访问其他应用preference对应的xml文件，如： 

```
File xmlFile = new File(“/data/data/cn.kieran.action/shared_prefs/testshare.xml”);。
```

