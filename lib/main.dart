// Copyright © 2020, 2021 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020  2021- Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ----------Código principal para Henutsen------------
// ----------------------------------------------------

// @dart=2.9
import 'package:csv_parser/csv_parser.dart';
import 'package:file_download/file_download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:henutsen_cli/configuration/areas_data.dart';
import 'package:henutsen_cli/configuration/areas_page.dart';
import 'package:henutsen_cli/configuration/businessLinesData.dart';
import 'package:henutsen_cli/configuration/businessLinesPage.dart';
import 'package:henutsen_cli/configuration/campus_data.dart';
import 'package:henutsen_cli/configuration/campus_page.dart';
import 'package:henutsen_cli/inAssets/countIn_assets.dart';
import 'package:henutsen_cli/inAssets/inAsset.dart';
import 'package:henutsen_cli/management/assetHistory.dart';
import 'package:henutsen_cli/management/assetOut_internal.dart';
import 'package:henutsen_cli/management/out_authorization.dart';
import 'package:henutsen_cli/management/paginateOut_internal.dart';
import 'package:henutsen_cli/management/pendient_data.dart';
import 'package:henutsen_cli/provider/area_model.dart';
import 'package:henutsen_cli/provider/assetHistory_model.dart';
import 'package:henutsen_cli/provider/campus_model.dart';
import 'package:henutsen_cli/provider/inventory_out.dart';
import 'package:henutsen_cli/provider/pendient_Authorization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:splashscreen/splashscreen.dart';

// Importar todas las páginas a usar
import 'package:henutsen_cli/inicio.dart';
import 'package:henutsen_cli/menu.dart';
import 'package:henutsen_cli/configuration/company_data.dart';
import 'package:henutsen_cli/configuration/company_page.dart';
import 'package:henutsen_cli/configuration/configuration_info.dart';
import 'package:henutsen_cli/configuration/configuration_page.dart';
import 'package:henutsen_cli/configuration/location_data.dart';
import 'package:henutsen_cli/configuration/location_page.dart';
import 'package:henutsen_cli/configuration/role_data.dart';
import 'package:henutsen_cli/configuration/role_page.dart';
import 'package:henutsen_cli/configuration/user_data.dart';
import 'package:henutsen_cli/configuration/user_page.dart';
import 'package:henutsen_cli/encoding/encoder_config.dart';
import 'package:henutsen_cli/encoding/encoding_info.dart';
import 'package:henutsen_cli/encoding/encoding_page.dart';
import 'package:henutsen_cli/encoding/encoding_page2.dart';
import 'package:henutsen_cli/encoding/encoding_password.dart';
import 'package:henutsen_cli/management/asset_data.dart';
import 'package:henutsen_cli/management/assets_following.dart';
import 'package:henutsen_cli/management/assets_list.dart';
import 'package:henutsen_cli/management/assets_management.dart';
import 'package:henutsen_cli/management/authorization_data.dart';
import 'package:henutsen_cli/management/category_data.dart';
import 'package:henutsen_cli/management/category_page.dart';
import 'package:henutsen_cli/management/management_info.dart';
import 'package:henutsen_cli/management/transfer_data.dart';
import 'package:henutsen_cli/printing/printer_config.dart';
import 'package:henutsen_cli/printing/printing_info.dart';
import 'package:henutsen_cli/printing/printing_page.dart';
import 'package:henutsen_cli/printing/printing_page2.dart';
import 'package:henutsen_cli/statistics/advanced_statistics.dart';
import 'package:henutsen_cli/statistics/download_reports.dart';
import 'package:henutsen_cli/statistics/statistics_info.dart';
import 'package:henutsen_cli/statistics/view_main_statistics.dart';
import 'package:henutsen_cli/statistics/view_missing_asset.dart';
import 'package:henutsen_cli/stocktaking/asset_search.dart';
import 'package:henutsen_cli/stocktaking/asset_search_main_page.dart';
import 'package:henutsen_cli/stocktaking/location_selection_page.dart';
import 'package:henutsen_cli/stocktaking/reader_config.dart';
import 'package:henutsen_cli/stocktaking/stocktaking_info.dart';
import 'package:henutsen_cli/stocktaking/stocktaking_page.dart';
import 'package:henutsen_cli/uploading/LoadFile/Model/decoded_asset.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/load_data.dart';
import 'package:henutsen_cli/uploading/LoadFile/Service/process_file.dart';
import 'package:henutsen_cli/uploading/LoadFile/asset_data_list_view.dart';
import 'package:henutsen_cli/uploading/LoadFile/asset_data_view.dart';
import 'package:henutsen_cli/uploading/LoadFile/upload_file_page.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/bulk_load.dart';
import 'package:henutsen_cli/uploading/ViewBulkUploads/view_bulk_load.dart';
import 'package:henutsen_cli/uploading/main_uploading_page.dart';
import 'package:henutsen_cli/uploading/uploading_info.dart';
import 'package:subscription/EditPlan/view_edit_plan.dart';
import 'package:subscription/ProviderState/state_plan_view.dart';
import 'package:subscription/ProviderState/subscription.dart';
import 'package:subscription/ViewPlan/preview_features.dart';
import 'package:subscription/ViewPlan/save_plan.dart';
import 'package:subscription/ViewPlan/view_plan.dart';

import 'package:henutsen_cli/globals.dart';
import 'package:henutsen_cli/provider/bluetooth_model.dart';
import 'package:henutsen_cli/provider/category_model.dart';
import 'package:henutsen_cli/provider/company_model.dart';
import 'package:henutsen_cli/provider/encoder_model.dart';
import 'package:henutsen_cli/provider/image_model.dart';
import 'package:henutsen_cli/provider/inventory_model.dart';
import 'package:henutsen_cli/provider/location_model.dart';
import 'package:henutsen_cli/provider/printer_model.dart';
import 'package:henutsen_cli/provider/role_model.dart';
import 'package:henutsen_cli/provider/statistics_model.dart';
import 'package:henutsen_cli/provider/transfer_model.dart';
import 'package:henutsen_cli/provider/user_model.dart';

import 'management/assets_internal.dart';

Future<void> main() async {
  // Always call this if the main method is asynchronous
  WidgetsFlutterBinding.ensureInitialized();
  // Load the JSON config into memory
  await Config.initialize();
  // Leer información interna de la aplicación
  henutsenAppInfo = await PackageInfo.fromPlatform();
  // Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = Config.sentryDSN
        // use breadcrumb tracking of platform Sentry SDKs
        ..useNativeBreadcrumbTracking();
      //options.reportSilentFlutterErrors;
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}

/// Clase principal
class MyApp extends StatelessWidget {
  ///  Class Key
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Henutsen';

    const mainColor = MaterialColor(
      0xFF4DBCC3,
      <int, Color>{
        50: Color(0xFF4DBCC3),
        100: Color(0xFF4DBCC3),
        200: Color(0xFF4DBCC3),
        300: Color(0xFF4DBCC3),
        400: Color(0xFF4DBCC3),
        500: Color(0xFF4DBCC3),
        600: Color(0xFF4DBCC3),
        700: Color(0xFF4DBCC3),
        800: Color(0xFF4DBCC3),
        900: Color(0xFF4DBCC3),
      },
    );

    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => FieldMappingModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => CompanyModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => InventoryModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => BluetoothModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => PrinterModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => EncoderModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => RoleModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => TransferModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatePlanViewProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DefaultDocumentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderSearch(),
        ),
        ChangeNotifierProvider(
          create: (_) => PendientModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => CampusModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AreaModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssetHistoryModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryOutModel(),
        ),
        ListenableProvider<CsvParserProvider<CsvAsset>>(
            create: (_) => CsvParserProvider<CsvAsset>()),
        ListenableProvider<LoadDataProvider>(create: (_) => LoadDataProvider()),
        ListenableProvider<DataFile>(create: (_) => DataFile()),
        ListenableProvider<BulkLoad>(create: (_) => BulkLoad()),
        ListenableProvider<FileDownload>(create: (_) => FileDownload()),
        ListenableProvider<StatisticsModel>(create: (_) => StatisticsModel()),
      ],
      child: MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: mainColor,
          primaryIconTheme: const IconThemeData.fallback().copyWith(
            color: Colors.white,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Define the default brightness and colors.
          brightness: Brightness.light,
          primaryColor: const Color.fromRGBO(77, 188, 195, 1),
          highlightColor: const Color.fromRGBO(238, 119, 126, 1),
          disabledColor: const Color.fromRGBO(178, 178, 178, 1),
          //accentColor: Colors.white,
          // Define the default font family.
          fontFamily: 'Lato',
          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: const TextTheme(
            headline1: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            headline2: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(77, 188, 195, 1)),
            headline3: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            headline4: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(77, 188, 195, 1)),
            headline5: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            bodyText1: TextStyle(fontSize: 14),
            button: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          // AppBarTheme
          appBarTheme: const AppBarTheme(
              foregroundColor: Colors.white //here you can give the text color
              ),
          // ButtonTheme
          buttonTheme: ButtonThemeData(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            buttonColor: const Color.fromRGBO(77, 188, 195, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textTheme: ButtonTextTheme.accent,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.orange, secondary: Colors.white), // Text color
          ),
          // ElevatedButtonTheme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              primary: const Color.fromRGBO(77, 188, 195, 1),
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // ScrollbarTheme
          scrollbarTheme: ScrollbarThemeData(
            isAlwaysShown: kIsWeb,
            thickness: MaterialStateProperty.resolveWith((states) => 17),
            thumbColor: MaterialStateProperty.resolveWith(
                (states) => const Color.fromRGBO(77, 188, 195, 0.4)),
            trackColor: MaterialStateProperty.resolveWith(
                (states) => Colors.grey.withOpacity(0.3)),
            showTrackOnHover: true,
            trackBorderColor: MaterialStateProperty.resolveWith(
                (states) => Colors.blueGrey.withOpacity(0.3)),
          ),
        ),
        // Start the app with the "/" named route. In this case, the app starts
        // on the FirstScreen widget.
        initialRoute: '/',
        //initialRoute: '/inicio',
        routes: <String, WidgetBuilder>{
          '/': (context) => const Splash(),
          '/inicio': (context) => const PagInicio(),
          '/menu': (context) => const MenuPage(),
          '/conteo-info': (context) => const StocktakingInfoPage(),
          '/conteo-sede': (context) => const StocktakingLocationPage(),
          '/conteo': (context) => const StocktakingPage(),
          '/buscar-lista': (context) => const AssetSearchMainPage(),
          '/buscar-activo': (context) => const AssetSearchPage(),
          '/config-lector': (context) => const ReaderConfigPage(),
          '/imprimir-info': (context) => const PrintingInfoPage(),
          '/imprimir': (context) => const PrintingPage(),
          '/imprimir2': (context) => const PrintingPage2(),
          '/config-impresora': (context) => const PrinterConfig(),
          '/codificar-info': (context) => const EncodingInfoPage(),
          '/codificar': (context) => const EncodingPage(),
          '/codificar2': (context) => const EncodingPage2(),
          '/codificar-contrasena': (context) => const PasswordPage(),
          '/config-codificador': (context) => const EncoderConfig(),
          '/subida-info': (context) => const UploadingInfoPage(),
          '/subida': (context) => const UploadPage(),
          '/config-info': (context) => const ConfigInfoPage(),
          '/config': (context) => const ConfigPage(),
          '/gestion-empresas': (context) => const CompanyManagement(),
          '/datos-empresa': (context) => const CompanyDataPage(),
          '/gestion-usuarios': (context) => const UserManagement(),
          '/datos-usuario': (context) => const UserDataPage(),
          '/gestion-ubicaciones': (context) => const LocationManagement(),
          '/datos-ubicacion': (context) => const LocationDataPage(),
          '/gestion-roles': (context) => const RoleManagementPage(),
          '/datos-rol': (context) => const RoleDataPage(),
          '/gestion-categorias': (context) => const CategoryManagement(),
          '/datos-categoria': (context) => const CategoryDataPage(),
          '/gestion-info': (context) => const ManagementInfoPage(),
          '/gestion-activos': (context) => const AssetsManagementPage(),
          '/lista-activos': (context) => const AssetsListPage(),
          '/datos-activo': (context) => const AssetDataPage(),
          '/traslado-activos': (context) => const AssetFollowingPage(),
          '/datos-traslados': (context) => const TransferDataPage(),
          '/datos-autorizar': (context) => const AuthorizationPage(),
          '/cargar-archivo': (context) => const UploadFilePage(),
          '/mapeo-campos': (context) => const AssetDataListView(),
          '/resumen-carga': (context) => const AssetDataViewPage(),
          '/ver-cargas': (context) => const ViewBulkLoad(),
          '/reportes-info': (context) => const StatisticsInfoPage(),
          '/reportes': (context) => const ViewMainStatistics(),
          '/activos-faltantes': (context) => const MissingAssetsPage(),
          '/descarga-reportes': (context) => const DownloadReportsPage(),
          '/reportes-avanzados': (context) => const AdvancedStatisticsPage(),
          '/solicitar-autorizacion': (context) => const PendientPage(),
          '/solicitar-salida': (context) => const OutAuthorization(),
          '/gestion-negocios': (context) => const BusinessManagement(),
          '/data-business': (context) => const BusinessDataPage(),
          '/campus-page': (context) => const CampusManagement(),
          '/campus-data': (context) => const CampusData(),
          '/area-page': (context) => const AreaManagement(),
          '/area-data': (context) => const AreaData(),
          '/asset-history': (context) => const HistoryAsset(),
          '/asset-internal': (context) => const AssetOutInternal(),
          '/internal-data': (context) => const TableAssetOut(),
          '/ingreso-activos': (context) => const IntAssets(),
          '/conteo-ingreso': (context) => const StocktakingInPage(),

          ///subscription
          '/viewPlan': (contex) => const IndexViewPlan(),
          '/savePlan': (contex) => const SavePlanView(),
          '/previewFeatures': (contex) => const IndexPreviewFeatures(),
          '/managementPlan': (_) => const IndexViewEditPlan(),
        },
        // Observador de Sentry
        navigatorObservers: [SentryNavigatorObserver()],
        builder: EasyLoading.init(),
      ),
    );
  }
}

/// Splash Screen de Henutsen
class Splash extends StatefulWidget {
  ///  Class Key
  const Splash({Key key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) => SplashScreen(
        seconds: 3,
        navigateAfterSeconds: const PagInicio(),
        title: const Text(
          'Su control de activos por\n'
          'multi-identificación a distancia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        image: Image.asset('images/logo_ini.png'),
        backgroundColor: Theme.of(context).primaryColor,
        styleTextUnderTheLoader: const TextStyle(),
        photoSize: 100,
        loaderColor: Colors.white,
      );
}
