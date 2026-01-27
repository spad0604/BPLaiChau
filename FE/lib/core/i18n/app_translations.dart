import 'package:get/get.dart';
import 'dart:ui';

/// GetX i18n translations.
///
/// Locale codes:
/// - vi_VN
/// - en_US
class AppTranslations extends Translations {
  static const viVN = Locale('vi', 'VN');
  static const enUS = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': {
          // Common
          'app.title': 'Biên phòng Lai Châu',
          'common.ok': 'OK',
          'common.cancel': 'Hủy',
          'common.close': 'Đóng',
          'common.save': 'Lưu',
          'common.delete': 'Xóa',
          'common.edit': 'Sửa',
          'common.search': 'Tìm kiếm',
          'common.loading': 'Đang tải...',
          'common.filter': 'Lọc',
          'common.export': 'Xuất',
          'common.exportReport': 'Xuất báo cáo',
          'common.error': 'Lỗi',
          'common.success': 'Thành công',
          'common.info': 'Thông báo',
          'common.logout': 'Đăng xuất',
          'common.active': 'Đang hoạt động',

          // Export
          'export.incidentsDone': 'Đã xuất báo cáo',
          'export.adminsDone': 'Đã xuất danh sách',

          // Roles
          'role.superAdmin': 'Quản trị tối cao',
          'role.admin': 'Quản trị viên',

          // Sidebar
          'sidebar.section': 'DANH MỤC',
          'sidebar.brandTitle': 'BĐBP Lai Châu',
          'sidebar.brandSubtitle': 'HỆ THỐNG QUẢN LÝ',
          'sidebar.cases': 'Danh sách chuyên án',
          'sidebar.createCase': 'Thêm chuyên án',
          'sidebar.stations': 'Quản lý đồn biên phòng',
          'sidebar.userManagement': 'Quản lý cán bộ',
          'sidebar.banners': 'Quản lý banner',

          // Dashboard titles/breadcrumbs
          'nav.breadcrumb.cases': 'Trang chủ  /  Quản lý chuyên án',
          'nav.title.cases': 'Danh sách chuyên án',
          'nav.breadcrumb.createCase': 'Hệ thống  /  Quản lý vụ việc  /  Thêm mới',
          'nav.title.createCase': 'Thêm vụ việc mới',
          'nav.breadcrumb.stations': 'Hệ thống  /  Danh mục  /  Đồn biên phòng',
          'nav.title.stations': 'Quản lý đồn biên phòng',
          'nav.breadcrumb.users': 'Hệ thống  /  Quản lý cán bộ',
          'nav.title.users': 'Quản lý cán bộ',
          'nav.breadcrumb.banners': 'Hệ thống  /  Banner',
          'nav.title.banners': 'Quản lý banner',

          // Cases
          'cases.headerDesc': 'Theo dõi, cập nhật và quản lý hồ sơ các chuyên án trên địa bàn tỉnh Lai Châu.',
          'cases.addNew': 'Thêm chuyên án mới',
          'cases.searchHintTitle': 'Tìm kiếm theo tiêu đề',
          'cases.filter.allStations': 'Tất cả đơn vị',
          'cases.filter.allStatuses': 'Tất cả trạng thái',
          'cases.filter.allYears': 'Tất cả năm',
          'cases.filter.advanced': 'Lọc nâng cao',
          'cases.filter.none': 'Không có bộ lọc',
          'cases.filter.yearChip': 'Năm: @year',
          'cases.filter.stationChip': 'Đơn vị: @station',
          'cases.filter.statusChip': 'Trạng thái: @status',
          'cases.filter.keywordChip': 'Từ khóa: @keyword',
          'cases.status.inProgress': 'Đang thụ lý',
          'cases.status.completed': 'Hoàn thành',
          'cases.table.code': 'MÃ HỒ SƠ',
          'cases.table.title': 'TÊN CHUYÊN ÁN / NỘI DUNG',
          'cases.table.station': 'ĐỒN BIÊN PHÒNG',
          'cases.table.area': 'ĐỊA BÀN',
          'cases.table.createdAt': 'NGÀY LẬP',
          'cases.table.status': 'TRẠNG THÁI',
          'cases.table.actions': 'TÁC VỤ',

          // Admins
          'admins.searchHint': 'Tìm theo tên, cấp bậc hoặc số hiệu...',
          'admins.officer': 'CÁN BỘ',
          'admins.unit': 'ĐƠN VỊ / ĐỒN',
          'admins.role': 'VAI TRÒ',
          'admins.status': 'TRẠNG THÁI',

          'admins.validation.usernamePassword': 'Vui lòng nhập username và password',
          'admins.updated': 'Đã cập nhật tài khoản',
          'admins.deleted': 'Đã xoá tài khoản',
        },
        'en_US': {
          // Common
          'app.title': 'Biên phòng Lai Châu',
          'common.ok': 'OK',
          'common.cancel': 'Cancel',
          'common.close': 'Close',
          'common.save': 'Save',
          'common.delete': 'Delete',
          'common.edit': 'Edit',
          'common.search': 'Search',
          'common.loading': 'Loading...',
          'common.filter': 'Filter',
          'common.export': 'Export',
          'common.exportReport': 'Export report',
          'common.error': 'Error',
          'common.success': 'Success',
          'common.info': 'Info',
          'common.logout': 'Logout',
          'common.active': 'Active',

          // Export
          'export.incidentsDone': 'Report exported',
          'export.adminsDone': 'List exported',

          // Roles
          'role.superAdmin': 'Super Admin',
          'role.admin': 'Admin',

          // Sidebar
          'sidebar.section': 'MENU',
          'sidebar.brandTitle': 'Border Guard Lai Chau',
          'sidebar.brandSubtitle': 'MANAGEMENT SYSTEM',
          'sidebar.cases': 'Case list',
          'sidebar.createCase': 'Create case',
          'sidebar.stations': 'Stations',
          'sidebar.userManagement': 'Users',
          'sidebar.banners': 'Banners',

          // Dashboard titles/breadcrumbs
          'nav.breadcrumb.cases': 'Home  /  Cases',
          'nav.title.cases': 'Case list',
          'nav.breadcrumb.createCase': 'System  /  Cases  /  Create',
          'nav.title.createCase': 'Create case',
          'nav.breadcrumb.stations': 'System  /  Directory  /  Stations',
          'nav.title.stations': 'Stations',
          'nav.breadcrumb.users': 'System  /  Users',
          'nav.title.users': 'Users',
          'nav.breadcrumb.banners': 'System  /  Banners',
          'nav.title.banners': 'Banners',

          // Cases
          'cases.headerDesc': 'Track, update and manage cases in Lai Chau province.',
          'cases.addNew': 'Add new case',
          'cases.searchHintTitle': 'Search by title',
          'cases.filter.allStations': 'All stations',
          'cases.filter.allStatuses': 'All statuses',
          'cases.filter.allYears': 'All years',
          'cases.filter.advanced': 'Advanced filters',
          'cases.filter.none': 'No filters',
          'cases.filter.yearChip': 'Year: @year',
          'cases.filter.stationChip': 'Station: @station',
          'cases.filter.statusChip': 'Status: @status',
          'cases.filter.keywordChip': 'Keyword: @keyword',
          'cases.status.inProgress': 'In progress',
          'cases.status.completed': 'Completed',
          'cases.table.code': 'CASE ID',
          'cases.table.title': 'CASE / CONTENT',
          'cases.table.station': 'STATION',
          'cases.table.area': 'AREA',
          'cases.table.createdAt': 'CREATED AT',
          'cases.table.status': 'STATUS',
          'cases.table.actions': 'ACTIONS',

          // Admins
          'admins.searchHint': 'Search by name, rank, or service number...',
          'admins.officer': 'OFFICER',
          'admins.unit': 'UNIT / STATION',
          'admins.role': 'ROLE',
          'admins.status': 'STATUS',

          'admins.validation.usernamePassword': 'Please enter username and password',
          'admins.updated': 'Account updated',
          'admins.deleted': 'Account deleted',
        },
      };
}
