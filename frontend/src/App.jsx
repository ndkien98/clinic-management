import React, { useState, useEffect, useCallback } from 'react';
import { 
  Activity, 
  Users, 
  Stethoscope, 
  BedDouble, 
  Pill, 
  Receipt, 
  BarChart3, 
  Plus, 
  Search, 
  CheckCircle2, 
  AlertCircle, 
  Clock, 
  Building2, 
  DollarSign, 
  UserCheck, 
  HeartHandshake,
  Calendar,
  FileText,
  RefreshCw,
  X,
  PackagePlus,
  ShieldCheck,
  Database,
  Trash2,
  Eye,
  Award,
  Layers,
  ChevronRight,
  TrendingUp,
  Cpu,
  Sparkles,
  ClipboardList,
  Menu
} from 'lucide-react';
import { patientApi, clinicApi, masterApi, API_BASE_URL } from './api/client';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [loading, setLoading] = useState(false);
  const [apiStatus, setApiStatus] = useState('connecting');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Dữ liệu từ API Backend / PostgreSQL
  const [patients, setPatients] = useState([]);
  const [treatmentCourses, setTreatmentCourses] = useState([]);
  const [medicines, setMedicines] = useState([]);
  const [invoices, setInvoices] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [diseases, setDiseases] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [availableBeds, setAvailableBeds] = useState([]);
  const [events, setEvents] = useState([]);
  const [stats, setStats] = useState({
    tongBenhNhan: 0,
    dotDieuTriDangMo: 0,
    giuongDangSuDung: 0,
    tongGiuong: 0,
    tongDoanhThu: 0,
  });
  const [deptRevenue, setDeptRevenue] = useState({});
  const [salaries, setSalaries] = useState([]);

  // Dữ liệu Master Data
  const [masterTab, setMasterTab] = useState('bac-sy');
  const [masterNurses, setMasterNurses] = useState([]);
  const [masterDevices, setMasterDevices] = useState([]);
  const [masterServices, setMasterServices] = useState([]);
  const [masterRooms, setMasterRooms] = useState([]);
  const [masterBeds, setMasterBeds] = useState([]);
  const [showAddMasterModal, setShowAddMasterModal] = useState(false);
  const [masterForm, setMasterForm] = useState({});

  // Dữ liệu Báo cáo theo tháng (Mục 2.1, 2.2, 3)
  const [selectedMonth, setSelectedMonth] = useState('2026-08');
  const [monthlyDiseases, setMonthlyDiseases] = useState([]);
  const [detailedRevenue, setDetailedRevenue] = useState({
    TienKham: 0,
    TienChua: 0,
    TienThuoc: 0,
    TienDichVu: 0,
    TienGiuongThietBi: 0,
    TongDoanhThu: 0,
  });
  const [detailedSalaries, setDetailedSalaries] = useState([]);

  // Modal Hồ Sơ 360°
  const [showHoSoModal, setShowHoSoModal] = useState(false);
  const [hoSoLoading, setHoSoLoading] = useState(false);
  const [hoSoData, setHoSoData] = useState(null);

  // Toast Notifications
  const [toasts, setToasts] = useState([]);

  const addToast = (type, message) => {
    const id = Date.now() + Math.random();
    setToasts((prev) => [...prev, { id, type, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4000);
  };

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  // Form states
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddPatientModal, setShowAddPatientModal] = useState(false);
  const [showRestockModal, setShowRestockModal] = useState(false);
  const [selectedMedForRestock, setSelectedMedForRestock] = useState(null);
  const [restockAmount, setRestockAmount] = useState(50);

  const [newPatient, setNewPatient] = useState({
    hoTen: '',
    gioiTinh: 'M',
    ngaySinh: '',
    sdt: '',
    soCCCD: '',
    diaChi: '',
  });

  // State form khám bệnh
  const [examForm, setExamForm] = useState({
    maBN: '',
    maBS: '',
    maKhoa: '',
    trieuChung: '',
    tienKham: 150000,
    openTreatment: false,
    maBenh: '',
    mucDoNang: 'Nhe',
    soLanChuaDuKien: 5,
    maGiuong: '',
  });

  // State form kê đơn thuốc
  const [rxForm, setRxForm] = useState({
    maSuKien: '',
    maThuoc: '',
    soLuong: 10,
  });

  // Formatters
  const formatVND = (num) =>
    new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num || 0);

  // Load all initial data from Backend REST API
  const fetchAllData = useCallback(async () => {
    setLoading(true);
    try {
      const [
        pRes,
        tcRes,
        mRes,
        iRes,
        dRes,
        docRes,
        disRes,
        rRes,
        bRes,
        evRes,
        stRes,
        drRes,
        salRes,
        nurseRes,
        devRes,
        servRes,
        bedRes
      ] = await Promise.allSettled([
        patientApi.getAll(),
        clinicApi.getTreatmentCourses(),
        clinicApi.getMedicines(),
        clinicApi.getInvoices(),
        clinicApi.getDepartments(),
        clinicApi.getDoctors(),
        clinicApi.getDiseases(),
        clinicApi.getRooms(),
        clinicApi.getAvailableBeds(),
        clinicApi.getEvents(),
        clinicApi.getStats(),
        clinicApi.getDepartmentRevenue(),
        clinicApi.getSalaries(),
        masterApi.getNurses(),
        masterApi.getDevices(),
        masterApi.getServices(),
        masterApi.getBeds(),
      ]);

      if (pRes.status === 'fulfilled' && pRes.value.data) {
        setPatients(pRes.value.data);
        if (pRes.value.data.length > 0 && !examForm.maBN) {
          setExamForm((prev) => ({ ...prev, maBN: pRes.value.data[0].maBN }));
        }
      }
      if (tcRes.status === 'fulfilled' && tcRes.value.data) setTreatmentCourses(tcRes.value.data);
      if (mRes.status === 'fulfilled' && mRes.value.data) {
        setMedicines(mRes.value.data);
        if (mRes.value.data.length > 0 && !rxForm.maThuoc) {
          setRxForm((prev) => ({ ...prev, maThuoc: mRes.value.data[0].maThuoc }));
        }
      }
      if (iRes.status === 'fulfilled' && iRes.value.data) setInvoices(iRes.value.data);
      if (dRes.status === 'fulfilled' && dRes.value.data) {
        setDepartments(dRes.value.data);
        if (dRes.value.data.length > 0 && !examForm.maKhoa) {
          setExamForm((prev) => ({ ...prev, maKhoa: dRes.value.data[0].maKhoa }));
        }
      }
      if (docRes.status === 'fulfilled' && docRes.value.data) {
        setDoctors(docRes.value.data);
        if (docRes.value.data.length > 0 && !examForm.maBS) {
          setExamForm((prev) => ({ ...prev, maBS: docRes.value.data[0].maBS }));
        }
      }
      if (disRes.status === 'fulfilled' && disRes.value.data) {
        setDiseases(disRes.value.data);
        if (disRes.value.data.length > 0 && !examForm.maBenh) {
          setExamForm((prev) => ({ ...prev, maBenh: disRes.value.data[0].maBenh }));
        }
      }
      if (rRes.status === 'fulfilled' && rRes.value.data) {
        setRooms(rRes.value.data);
        setMasterRooms(rRes.value.data);
      }
      if (bRes.status === 'fulfilled' && bRes.value.data) setAvailableBeds(bRes.value.data);
      if (evRes.status === 'fulfilled' && evRes.value.data) {
        setEvents(evRes.value.data);
        if (evRes.value.data.length > 0 && !rxForm.maSuKien) {
          setRxForm((prev) => ({ ...prev, maSuKien: evRes.value.data[0].maSuKien }));
        }
      }
      if (stRes.status === 'fulfilled' && stRes.value.data) setStats(stRes.value.data);
      if (drRes.status === 'fulfilled' && drRes.value.data) setDeptRevenue(drRes.value.data);
      if (salRes.status === 'fulfilled' && salRes.value.data) setSalaries(salRes.value.data);
      if (nurseRes.status === 'fulfilled' && nurseRes.value.data) setMasterNurses(nurseRes.value.data);
      if (devRes.status === 'fulfilled' && devRes.value.data) setMasterDevices(devRes.value.data);
      if (servRes.status === 'fulfilled' && servRes.value.data) setMasterServices(servRes.value.data);
      if (bedRes.status === 'fulfilled' && bedRes.value.data) setMasterBeds(bedRes.value.data);

      setApiStatus('connected');
    } catch (err) {
      setApiStatus('error');
      addToast('error', `Không thể kết nối đến Backend (${API_BASE_URL}): ` + (err.message || 'Lỗi mạng'));
    } finally {
      setLoading(false);
    }
  }, []);

  // Fetch báo cáo theo tháng (Mục 2.1, 2.2, 3)
  const fetchMonthlyReports = useCallback(async (month) => {
    try {
      const [disRes, revRes, salRes] = await Promise.allSettled([
        clinicApi.getDiseasesMonthly(month),
        clinicApi.getDetailedRevenue(month),
        clinicApi.getDetailedSalaries(month),
      ]);
      if (disRes.status === 'fulfilled' && disRes.value.data) setMonthlyDiseases(disRes.value.data);
      if (revRes.status === 'fulfilled' && revRes.value.data) setDetailedRevenue(revRes.value.data);
      if (salRes.status === 'fulfilled' && salRes.value.data) setDetailedSalaries(salRes.value.data);
    } catch (err) {
      addToast('error', 'Lỗi tải báo cáo tháng: ' + (err.message || ''));
    }
  }, []);

  useEffect(() => {
    fetchAllData();
  }, [fetchAllData]);

  useEffect(() => {
    if (activeTab === 'reports') {
      fetchMonthlyReports(selectedMonth);
    }
  }, [activeTab, selectedMonth, fetchMonthlyReports]);

  // Mở Hồ Sơ Bệnh Nhân 360° (Mục 1.b)
  const handleOpenHoSo360 = async (maBN) => {
    setHoSoLoading(true);
    setShowHoSoModal(true);
    try {
      const res = await patientApi.getHoSo360(maBN);
      setHoSoData(res.data);
    } catch (err) {
      addToast('error', 'Không thể tải hồ sơ 360: ' + (err.message || ''));
    } finally {
      setHoSoLoading(false);
    }
  };

  // Tiếp nhận bệnh nhân mới (POST vào DB)
  const handleAddPatient = async (e) => {
    e.preventDefault();
    try {
      const res = await patientApi.create(newPatient);
      addToast('success', `Đã tiếp nhận bệnh nhân thành công! Mã BN: ${res.data.maBN}`);
      setShowAddPatientModal(false);
      setNewPatient({ hoTen: '', gioiTinh: 'M', ngaySinh: '', sdt: '', soCCCD: '', diaChi: '' });
      const updated = await patientApi.getAll();
      setPatients(updated.data);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi khi lưu bệnh nhân';
      addToast('error', `Thất bại: ${msg}`);
    }
  };

  // Xóa bệnh nhân
  const handleDeletePatient = async (maBN) => {
    if (!window.confirm(`Bạn có chắc chắn muốn xóa hồ sơ bệnh nhân ${maBN}?`)) return;
    try {
      await patientApi.delete(maBN);
      addToast('success', `Đã xóa hồ sơ bệnh nhân ${maBN} khỏi CSDL!`);
      const updated = await patientApi.getAll();
      setPatients(updated.data);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi xóa bệnh nhân';
      addToast('error', `Thất bại: ${msg}`);
    }
  };

  // Lưu khám bệnh & mở đợt điều trị
  const handleSaveExamination = async (e) => {
    e.preventDefault();
    if (!examForm.maBN || !examForm.maBS || !examForm.maKhoa) {
      addToast('warning', 'Vui lòng chọn đầy đủ Bệnh nhân, Bác sĩ và Khoa khám!');
      return;
    }

    try {
      const resExam = await clinicApi.createExamination({
        maBN: examForm.maBN,
        maBS: examForm.maBS,
        maKhoa: examForm.maKhoa,
        trieuChung: examForm.trieuChung,
        tienKham: examForm.tienKham,
      });

      const maSuKien = resExam.data.maSuKien;
      addToast('success', `Đã lưu khám bệnh thành công! Mã sự kiện: ${maSuKien}`);

      if (examForm.openTreatment) {
        if (!examForm.maBenh) {
          addToast('warning', 'Chưa chọn mã bệnh để mở đợt điều trị!');
        } else {
          const resDot = await clinicApi.createTreatmentCourse({
            maSuKienKham: maSuKien,
            maBenh: examForm.maBenh,
            mucDoNang: examForm.mucDoNang,
            soLanChuaDuKien: examForm.soLanChuaDuKien,
            maGiuong: examForm.maGiuong || null,
          });
          addToast('success', `Đã mở đợt điều trị mới: ${resDot.data.maDotDieuTri} (Giường: ${examForm.maGiuong || 'Ngoại trú'})`);
        }
      }

      setExamForm((prev) => ({ ...prev, trieuChung: '', openTreatment: false }));
      fetchAllData();
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi lưu khám bệnh';
      addToast('error', `Lỗi khám bệnh: ${msg}`);
    }
  };

  // Kê đơn thuốc
  const handlePrescribeMedicine = async (e) => {
    e.preventDefault();
    if (!rxForm.maSuKien || !rxForm.maThuoc || !rxForm.soLuong) {
      addToast('warning', 'Vui lòng điền đủ thông tin kê đơn!');
      return;
    }

    try {
      await clinicApi.prescribeMedicine({
        maSuKien: rxForm.maSuKien,
        maThuoc: rxForm.maThuoc,
        soLuong: parseInt(rxForm.soLuong, 10),
      });

      addToast('success', `Đã kê đơn thành công! Tồn kho thuốc đã được tự động trừ trong CSDL.`);
      const [mRes, iRes] = await Promise.all([clinicApi.getMedicines(), clinicApi.getInvoices()]);
      setMedicines(mRes.data);
      setInvoices(iRes.data);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi kê đơn thuốc';
      addToast('error', `Kê đơn thất bại: ${msg}`);
    }
  };

  // Đóng đợt điều trị (Kết luận khỏi bệnh)
  const handleCloseTreatment = async (maDot) => {
    try {
      await clinicApi.closeTreatmentCourse(maDot);
      addToast('success', `Đã đóng đợt điều trị ${maDot}! Trạng thái chuyển 'Đã khỏi' và giải phóng giường bệnh.`);
      const [tcRes, bRes] = await Promise.all([clinicApi.getTreatmentCourses(), clinicApi.getAvailableBeds()]);
      setTreatmentCourses(tcRes.data);
      setAvailableBeds(bRes.data);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi đóng đợt điều trị';
      addToast('error', `Thất bại: ${msg}`);
    }
  };

  // Xác nhận thu phí viện phí
  const handlePayInvoice = async (maSuKien) => {
    try {
      await clinicApi.payInvoice(maSuKien);
      addToast('success', `Hóa đơn sự kiện ${maSuKien} đã được thanh toán thành công vào CSDL!`);
      const [iRes, sRes] = await Promise.all([clinicApi.getInvoices(), clinicApi.getStats()]);
      setInvoices(iRes.data);
      setStats(sRes.data);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi thanh toán hóa đơn';
      addToast('error', `Thanh toán thất bại: ${msg}`);
    }
  };

  // Nhập thêm thuốc vào kho
  const handleRestock = async () => {
    if (!selectedMedForRestock) return;
    try {
      await clinicApi.restockMedicine(selectedMedForRestock.maThuoc, parseInt(restockAmount, 10));
      addToast('success', `Đã nhập thêm ${restockAmount} ${selectedMedForRestock.donViTinh} cho thuốc ${selectedMedForRestock.tenThuoc}!`);
      setShowRestockModal(false);
      const mRes = await clinicApi.getMedicines();
      setMedicines(mRes.data);
    } catch (err) {
      addToast('error', 'Lỗi nhập kho: ' + (err.message || 'Không thành công'));
    }
  };

  // Thêm mới Master Data theo subtab
  const handleAddMasterData = async (e) => {
    e.preventDefault();
    try {
      if (masterTab === 'bac-sy') {
        await masterApi.createDoctor(masterForm);
        addToast('success', 'Đã thêm Bác sĩ mới vào CSDL!');
        const res = await clinicApi.getDoctors();
        setDoctors(res.data);
      } else if (masterTab === 'y-ta') {
        await masterApi.createNurse(masterForm);
        addToast('success', 'Đã thêm Y tá mới vào CSDL!');
        const res = await masterApi.getNurses();
        setMasterNurses(res.data);
      } else if (masterTab === 'danh-muc-benh') {
        await masterApi.createDisease(masterForm);
        addToast('success', 'Đã thêm Danh mục bệnh mới vào CSDL!');
        const res = await clinicApi.getDiseases();
        setDiseases(res.data);
      } else if (masterTab === 'thiet-bi') {
        await masterApi.createDevice(masterForm);
        addToast('success', 'Đã thêm Thiết bị y tế mới vào CSDL!');
        const res = await masterApi.getDevices();
        setMasterDevices(res.data);
      } else if (masterTab === 'dich-vu') {
        await masterApi.createService(masterForm);
        addToast('success', 'Đã thêm Dịch vụ y tế mới vào CSDL!');
        const res = await masterApi.getServices();
        setMasterServices(res.data);
      } else if (masterTab === 'phong-kham') {
        await masterApi.createRoom(masterForm);
        addToast('success', 'Đã thêm Phòng khám mới vào CSDL!');
        const res = await clinicApi.getRooms();
        setRooms(res.data);
        setMasterRooms(res.data);
      } else if (masterTab === 'giuong-benh') {
        await masterApi.createBed(masterForm);
        addToast('success', 'Đã thêm Giường bệnh mới vào CSDL!');
        const res = await masterApi.getBeds();
        setMasterBeds(res.data);
      }
      setShowAddMasterModal(false);
      setMasterForm({});
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi thêm mới danh mục';
      addToast('error', `Thất bại: ${msg}`);
    }
  };

  // Xóa Master Data
  const handleDeleteMasterData = async (type, id) => {
    if (!window.confirm(`Bạn có chắc chắn muốn xóa bản ghi [${id}]?`)) return;
    try {
      if (type === 'bac-sy') {
        await masterApi.deleteDoctor(id);
        setDoctors(doctors.filter((d) => d.maBS !== id));
      } else if (type === 'y-ta') {
        await masterApi.deleteNurse(id);
        setMasterNurses(masterNurses.filter((n) => n.maYTa !== id));
      } else if (type === 'danh-muc-benh') {
        await masterApi.deleteDisease(id);
        setDiseases(diseases.filter((d) => d.maBenh !== id));
      } else if (type === 'thiet-bi') {
        await masterApi.deleteDevice(id);
        setMasterDevices(masterDevices.filter((d) => d.maTB !== id));
      } else if (type === 'dich-vu') {
        await masterApi.deleteService(id);
        setMasterServices(masterServices.filter((s) => s.maDV !== id));
      } else if (type === 'phong-kham') {
        await masterApi.deleteRoom(id);
        setMasterRooms(masterRooms.filter((r) => r.maPhong !== id));
      } else if (type === 'giuong-benh') {
        await masterApi.deleteBed(id);
        setMasterBeds(masterBeds.filter((b) => b.maGiuong !== id));
      }
      addToast('success', `Đã xóa thành công bản ghi [${id}] khỏi CSDL!`);
    } catch (err) {
      const msg = err.response?.data?.message || err.message || 'Lỗi khi xóa';
      addToast('error', `Không thể xóa: ${msg}`);
    }
  };

  const navItems = [
    { id: 'dashboard', label: 'Bảng Điều Khiển', icon: Activity },
    { id: 'reception', label: 'Tiếp Nhận & Bệnh Nhân', icon: Users },
    { id: 'examination', label: 'Khám Bệnh & Kê Đơn', icon: Stethoscope },
    { id: 'treatment', label: 'Đợt Điều Trị & Giường', icon: BedDouble },
    { id: 'pharmacy', label: 'Kho Dược Phẩm', icon: Pill },
    { id: 'billing', label: 'Thu Ngân & Viện Phí', icon: Receipt },
    { id: 'master', label: 'Quản Lý Danh Mục', icon: Database },
    { id: 'reports', label: 'Báo Cáo Thống Kê', icon: BarChart3 },
  ];

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden font-['Plus_Jakarta_Sans',sans-serif]">
      {/* Toast Notification Container */}
      <div className="fixed top-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none">
        {toasts.map((t) => (
          <div
            key={t.id}
            className={`pointer-events-auto flex items-start gap-3 p-4 rounded-xl border shadow-lg backdrop-blur-md transition-all duration-300 transform translate-y-0 ${
              t.type === 'success'
                ? 'bg-emerald-900/90 text-white border-emerald-500'
                : t.type === 'error'
                ? 'bg-rose-900/90 text-white border-rose-500'
                : 'bg-amber-900/90 text-white border-amber-500'
            }`}
          >
            {t.type === 'success' ? (
              <CheckCircle2 className="w-5 h-5 text-emerald-300 shrink-0 mt-0.5" />
            ) : t.type === 'error' ? (
              <AlertCircle className="w-5 h-5 text-rose-300 shrink-0 mt-0.5" />
            ) : (
              <Clock className="w-5 h-5 text-amber-300 shrink-0 mt-0.5" />
            )}
            <div className="flex-1 text-xs leading-relaxed font-medium">{t.message}</div>
            <button
              onClick={() => removeToast(t.id)}
              className="text-slate-300 hover:text-white transition"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        ))}
      </div>

      {/* Mobile Drawer Backdrop */}
      {mobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs z-40 md:hidden transition-opacity"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar Navigation (Desktop + Mobile Slide-over Drawer) */}
      <aside className={`fixed md:static inset-y-0 left-0 w-72 md:w-64 bg-slate-900 text-white flex flex-col justify-between shadow-2xl md:shadow-xl z-50 md:z-20 transform transition-transform duration-300 ease-in-out shrink-0 ${
        mobileMenuOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
      }`}>
        <div>
          <div className="h-16 flex items-center justify-between px-6 border-b border-slate-800 bg-slate-950/40">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-lg bg-teal-500 flex items-center justify-center shadow-lg shadow-teal-500/30">
                <Stethoscope className="w-5 h-5 text-white" />
              </div>
              <div>
                <span className="font-bold text-base tracking-tight text-white block leading-none">CLINIC MASTER</span>
                <span className="text-[10px] text-teal-400 font-medium tracking-wider">HỆ CSDL PHÒNG KHÁM</span>
              </div>
            </div>
            {/* Close Button on Mobile */}
            <button
              onClick={() => setMobileMenuOpen(false)}
              className="md:hidden p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
              title="Đóng menu"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <nav className="p-4 space-y-1.5 overflow-y-auto max-h-[calc(100vh-14rem)]">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = activeTab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => {
                    setActiveTab(item.id);
                    setMobileMenuOpen(false);
                  }}
                  className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all ${
                    isActive
                      ? 'bg-teal-600 text-white shadow-md shadow-teal-900/40'
                      : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                  {item.label}
                </button>
              );
            })}
          </nav>
        </div>

        <div className="p-4 border-t border-slate-800 bg-slate-950/20 space-y-3">
          <div className="bg-slate-800/60 rounded-lg p-3 text-xs">
            <div className="flex items-center justify-between text-slate-400 mb-1">
              <span>CSDL Trực Tuyến</span>
              <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-emerald-500/20 text-emerald-400">
                PostgreSQL
              </span>
            </div>
            <p className="text-white font-medium truncate">Database: phong_kham2</p>
            <p className="text-[11px] text-slate-400">REST API • Port 8080</p>
          </div>

          <button
            onClick={fetchAllData}
            disabled={loading}
            className="w-full flex items-center justify-center gap-2 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs font-medium transition"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            {loading ? 'Đang đồng bộ...' : 'Đồng bộ lại CSDL'}
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top Header */}
        <header className="h-16 bg-white border-b border-slate-200/80 px-4 sm:px-8 flex items-center justify-between shadow-xs shrink-0">
          <div className="flex items-center gap-2 sm:gap-3 min-w-0">
            {/* Hamburger Button on Mobile */}
            <button
              onClick={() => setMobileMenuOpen(true)}
              className="md:hidden p-2 text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition"
              title="Mở thanh điều hướng"
            >
              <Menu className="w-5 h-5" />
            </button>
            <div className="truncate">
              <h1 className="text-base sm:text-lg font-bold text-slate-800 truncate">
                {navItems.find((n) => n.id === activeTab)?.label}
              </h1>
              <p className="text-[11px] text-slate-500 hidden sm:block truncate">Phòng khám đa khoa tư nhân • Quản lý chuyên sâu & Đợt điều trị BCNF</p>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-3">
            {/* Backend Connection Status Badge */}
            <div 
              className={`flex items-center gap-1.5 px-2 sm:px-2.5 py-1 rounded-full text-[10px] sm:text-[11px] font-medium border transition-all ${
                apiStatus === 'connected' 
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200' 
                  : apiStatus === 'connecting'
                  ? 'bg-amber-50 text-amber-700 border-amber-200'
                  : 'bg-rose-50 text-rose-700 border-rose-200'
              }`} 
              title={`Cấu hình Backend API Base URL từ .env: ${API_BASE_URL}`}
            >
              <span className={`w-2 h-2 rounded-full ${
                apiStatus === 'connected' 
                  ? 'bg-emerald-500 animate-pulse' 
                  : apiStatus === 'connecting'
                  ? 'bg-amber-500 animate-ping'
                  : 'bg-rose-500'
              }`} />
              <span>{apiStatus === 'connected' ? 'BE Online' : apiStatus === 'connecting' ? 'Connecting...' : 'BE Offline'}</span>
              <span className="text-[10px] opacity-75 font-mono hidden lg:inline">({API_BASE_URL})</span>
            </div>

            {/* Refresh Data Button */}
            <button
              onClick={fetchAllData}
              disabled={loading}
              className="p-1.5 text-slate-500 hover:text-teal-600 hover:bg-slate-100 rounded-lg transition border border-slate-200 shadow-2xs"
              title="Đồng bộ lại toàn bộ dữ liệu từ Backend"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin text-teal-600' : ''}`} />
            </button>

            <div className="relative hidden md:block">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Tìm bệnh nhân, SĐT, CCCD..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 pr-4 py-1.5 text-xs bg-slate-100 rounded-lg border-0 focus:ring-2 focus:ring-teal-500 w-44 lg:w-64 text-slate-700"
              />
            </div>

            <button
              onClick={() => setShowAddPatientModal(true)}
              className="flex items-center gap-1 sm:gap-1.5 px-2.5 sm:px-3 py-1.5 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition shrink-0"
            >
              <Plus className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Tiếp Nhận Mới</span>
              <span className="sm:hidden">Thêm</span>
            </button>
          </div>
        </header>

        {/* Scrollable Page Body */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 md:p-8 pb-24 md:pb-8">
          {/* TAB 1: DASHBOARD */}
          {activeTab === 'dashboard' && (
            <div className="space-y-6">
              {/* Stat Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5">
                <div className="bg-white p-5 rounded-xl border border-slate-200/70 shadow-xs">
                  <div className="flex justify-between items-center text-slate-500 text-xs font-semibold uppercase tracking-wider">
                    Tổng Bệnh Nhân
                    <div className="p-2 bg-teal-50 rounded-lg text-teal-600">
                      <Users className="w-4 h-4" />
                    </div>
                  </div>
                  <div className="text-2xl font-extrabold text-slate-900 mt-2">
                    {stats.tongBenhNhan || patients.length}
                  </div>
                  <div className="text-[11px] text-emerald-600 font-medium mt-1">Lưu trữ trong CSDL phong_kham2</div>
                </div>

                <div className="bg-white p-5 rounded-xl border border-slate-200/70 shadow-xs">
                  <div className="flex justify-between items-center text-slate-500 text-xs font-semibold uppercase tracking-wider">
                    Đợt Điều Trị Mở
                    <div className="p-2 bg-indigo-50 rounded-lg text-indigo-600">
                      <HeartHandshake className="w-4 h-4" />
                    </div>
                  </div>
                  <div className="text-2xl font-extrabold text-slate-900 mt-2">
                    {treatmentCourses.filter((t) => t.trangThai === 'DangDieuTri').length}
                  </div>
                  <div className="text-[11px] text-indigo-600 font-medium mt-1">Theo dõi phác đồ liên tục</div>
                </div>

                <div className="bg-white p-5 rounded-xl border border-slate-200/70 shadow-xs">
                  <div className="flex justify-between items-center text-slate-500 text-xs font-semibold uppercase tracking-wider">
                    Giường Bệnh Đang Dùng
                    <div className="p-2 bg-amber-50 rounded-lg text-amber-600">
                      <BedDouble className="w-4 h-4" />
                    </div>
                  </div>
                  <div className="text-2xl font-extrabold text-slate-900 mt-2">
                    {stats.giuongDangSuDung || 0}
                  </div>
                  <div className="text-[11px] text-amber-600 font-medium mt-1">
                    Còn trống: {availableBeds.length} giường
                  </div>
                </div>

                <div className="bg-white p-5 rounded-xl border border-slate-200/70 shadow-xs">
                  <div className="flex justify-between items-center text-slate-500 text-xs font-semibold uppercase tracking-wider">
                    Doanh Thu Đã Thu Phí
                    <div className="p-2 bg-emerald-50 rounded-lg text-emerald-600">
                      <DollarSign className="w-4 h-4" />
                    </div>
                  </div>
                  <div className="text-2xl font-extrabold text-slate-900 mt-2">
                    {formatVND(stats.tongDoanhThu || invoices.filter(i => i.trangThaiTT === 'DaThanhToan').reduce((a, b) => a + Number(b.tongTien), 0))}
                  </div>
                  <div className="text-[11px] text-emerald-600 font-medium mt-1">Thực thu vào quỹ phòng khám</div>
                </div>
              </div>

              {/* Grid 2 Columns */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Đợt điều trị gần nhất */}
                <div className="bg-white rounded-xl border border-slate-200/70 p-6 shadow-xs">
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="text-sm font-bold text-slate-800 flex items-center gap-2">
                      <Clock className="w-4 h-4 text-teal-600" />
                      Đợt Điều Trị Đang Diễn Ra (DotDieuTri)
                    </h2>
                    <span className="text-xs text-slate-400">Chuẩn BCNF</span>
                  </div>
                  <div className="divide-y divide-slate-100">
                    {treatmentCourses.length === 0 ? (
                      <p className="text-xs text-slate-400 py-3">Chưa có đợt điều trị nào trong CSDL.</p>
                    ) : (
                      treatmentCourses.slice(0, 5).map((tc) => (
                        <div key={tc.maDotDieuTri} className="py-3 flex items-center justify-between">
                          <div>
                            <div className="flex items-center gap-2">
                              <span className="font-semibold text-xs text-slate-800 font-mono text-teal-700">
                                {tc.maDotDieuTri}
                              </span>
                              <span className="text-[10px] px-2 py-0.5 rounded-full bg-slate-100 text-slate-600">
                                Bệnh: {tc.maBenh}
                              </span>
                            </div>
                            <p className="text-[11px] text-slate-400 mt-1">
                              Bắt đầu: {tc.ngayBatDau} • Giường: {tc.maGiuong || 'Điều trị ngoại trú'}
                            </p>
                          </div>
                          <div className="flex items-center gap-2">
                            <span
                              className={`text-xs px-2.5 py-1 rounded-full font-medium ${
                                tc.trangThai === 'DangDieuTri'
                                    ? 'bg-blue-50 text-blue-700 border border-blue-200'
                                    : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                              }`}
                            >
                              {tc.trangThai === 'DangDieuTri' ? 'Đang điều trị' : 'Đã khỏi'}
                            </span>
                            {tc.trangThai === 'DangDieuTri' && (
                              <button
                                onClick={() => handleCloseTreatment(tc.maDotDieuTri)}
                                className="px-2 py-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded text-[10px] font-semibold transition"
                              >
                                Khỏi bệnh
                              </button>
                            )}
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>

                {/* Kho thuốc & Cảnh báo tồn */}
                <div className="bg-white rounded-xl border border-slate-200/70 p-6 shadow-xs">
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="text-sm font-bold text-slate-800 flex items-center gap-2">
                      <Pill className="w-4 h-4 text-teal-600" />
                      Tồn Kho Dược Phẩm (Bảng Thuoc)
                    </h2>
                    <span className="text-xs text-slate-400">Trigger Auto Check</span>
                  </div>
                  <div className="divide-y divide-slate-100">
                    {medicines.slice(0, 5).map((med) => (
                      <div key={med.maThuoc} className="py-3 flex items-center justify-between">
                        <div>
                          <p className="text-xs font-semibold text-slate-800">{med.tenThuoc}</p>
                          <p className="text-[11px] text-slate-500">
                            {formatVND(med.donGia)} / {med.donViTinh} • SX: {med.hangSX || 'Nội địa'}
                          </p>
                        </div>
                        <div className="text-right">
                          <span className={`text-xs font-bold ${med.tonKho < 200 ? 'text-rose-600' : 'text-slate-800'}`}>
                            {med.tonKho} {med.donViTinh}
                          </span>
                          <button
                            onClick={() => {
                              setSelectedMedForRestock(med);
                              setShowRestockModal(true);
                            }}
                            className="block text-[10px] text-teal-600 hover:underline mt-0.5"
                          >
                            + Nhập kho
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: RECEPTION & PATIENTS (Có nút Hồ sơ 360°) */}
          {activeTab === 'reception' && (
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <p className="text-xs text-slate-500">Hồ sơ bệnh nhân trong CSDL (bảng benhnhan) • Bấm "Hồ sơ 360°" để xem chi tiết bệnh hiện tại và lịch sử viện phí</p>
                <button
                  onClick={() => setShowAddPatientModal(true)}
                  className="px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 flex items-center gap-1.5 shadow-sm transition"
                >
                  <Plus className="w-4 h-4" /> Thêm Bệnh Nhân
                </button>
              </div>

              <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                    <tr>
                      <th className="p-3.5">Mã BN</th>
                      <th className="p-3.5">Họ Và Tên</th>
                      <th className="p-3.5">Giới Tính</th>
                      <th className="p-3.5">Ngày Sinh</th>
                      <th className="p-3.5">Số CCCD</th>
                      <th className="p-3.5">Số Điện Thoại</th>
                      <th className="p-3.5">Địa Chỉ</th>
                      <th className="p-3.5 text-right">Thao Tác Nghiệp Vụ</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-slate-700">
                    {patients
                      .filter(
                        (p) =>
                          p.hoTen?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          p.maBN?.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          p.sdt?.includes(searchQuery) ||
                          p.soCCCD?.includes(searchQuery)
                      )
                      .map((p) => (
                        <tr key={p.maBN} className="hover:bg-slate-50/80 transition-colors">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{p.maBN}</td>
                          <td className="p-3.5 font-medium text-slate-900">{p.hoTen}</td>
                          <td className="p-3.5">
                            <span className={`px-2 py-0.5 rounded text-[10px] font-semibold ${p.gioiTinh === 'M' ? 'bg-blue-50 text-blue-700' : 'bg-pink-50 text-pink-700'}`}>
                              {p.gioiTinh === 'M' ? 'Nam' : 'Nữ'}
                            </span>
                          </td>
                          <td className="p-3.5">{p.ngaySinh || '---'}</td>
                          <td className="p-3.5 font-mono">{p.soCCCD || '---'}</td>
                          <td className="p-3.5">{p.sdt || '---'}</td>
                          <td className="p-3.5 text-slate-500">{p.diaChi || '---'}</td>
                          <td className="p-3.5 text-right space-x-2">
                            <button
                              onClick={() => handleOpenHoSo360(p.maBN)}
                              className="inline-flex items-center gap-1 px-2.5 py-1 bg-teal-50 text-teal-700 hover:bg-teal-100 rounded text-[11px] font-semibold transition"
                            >
                              <Eye className="w-3 h-3" /> Hồ Sơ 360°
                            </button>
                            <button
                              onClick={() => handleDeletePatient(p.maBN)}
                              className="inline-flex items-center gap-1 px-2 py-1 text-rose-600 hover:bg-rose-50 rounded text-[11px] transition"
                            >
                              <Trash2 className="w-3 h-3" />
                            </button>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 3: EXAMINATION & RX */}
          {activeTab === 'examination' && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Form Khám Bệnh Thực Tế */}
              <div className="lg:col-span-2 bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs space-y-4">
                <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <Stethoscope className="w-4 h-4 text-teal-600" />
                  Tiếp Nhận & Ghi Nhận Khám Bệnh (LanKham sang PostgreSQL)
                </h2>
                <form onSubmit={handleSaveExamination} className="space-y-4 text-xs">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                    <div>
                      <label className="block text-slate-600 font-medium mb-1">Chọn Bệnh Nhân *</label>
                      <select
                        value={examForm.maBN}
                        onChange={(e) => setExamForm({ ...examForm, maBN: e.target.value })}
                        className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                        required
                      >
                        <option value="">-- Chọn bệnh nhân --</option>
                        {patients.map((p) => (
                          <option key={p.maBN} value={p.maBN}>
                            {p.maBN} - {p.hoTen}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-slate-600 font-medium mb-1">Bác Sĩ Khám (BacSy) *</label>
                      <select
                        value={examForm.maBS}
                        onChange={(e) => setExamForm({ ...examForm, maBS: e.target.value })}
                        className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                        required
                      >
                        <option value="">-- Chọn bác sĩ --</option>
                        {doctors.map((d) => (
                          <option key={d.maBS} value={d.maBS}>
                            {d.maBS} - {d.chuyenMon || 'Bác sĩ chuyên khoa'}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-slate-600 font-medium mb-1">Khoa Khám (Khoa) *</label>
                      <select
                        value={examForm.maKhoa}
                        onChange={(e) => setExamForm({ ...examForm, maKhoa: e.target.value })}
                        className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                        required
                      >
                        <option value="">-- Chọn khoa --</option>
                        {departments.map((dept) => (
                          <option key={dept.maKhoa} value={dept.maKhoa}>
                            {dept.maKhoa} - {dept.tenKhoa}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-slate-600 font-medium mb-1">Tiền Khám (VND) *</label>
                      <input
                        type="number"
                        value={examForm.tienKham}
                        onChange={(e) => setExamForm({ ...examForm, tienKham: parseFloat(e.target.value) })}
                        className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 font-bold"
                        required
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Triệu Chứng & Chẩn Đoán Ban Đầu</label>
                    <textarea
                      rows={2}
                      placeholder="Mô tả triệu chứng bệnh nhân khai báo..."
                      value={examForm.trieuChung}
                      onChange={(e) => setExamForm({ ...examForm, trieuChung: e.target.value })}
                      className="w-full p-2 text-xs border border-slate-200 rounded-lg bg-slate-50"
                    ></textarea>
                  </div>

                  {/* Section Tùy chọn Mở Đợt Điều Trị */}
                  <div className="bg-slate-50 p-4 rounded-xl border border-slate-200/80 space-y-3">
                    <div className="flex items-center gap-2">
                      <input
                        type="checkbox"
                        id="openTreatmentCheckbox"
                        checked={examForm.openTreatment}
                        onChange={(e) => setExamForm({ ...examForm, openTreatment: e.target.checked })}
                        className="rounded text-teal-600 w-4 h-4 cursor-pointer"
                      />
                      <label htmlFor="openTreatmentCheckbox" className="font-bold text-slate-800 cursor-pointer">
                        Mở Đợt Điều Trị Mới Cho Ca Bệnh Này (DotDieuTri)
                      </label>
                    </div>

                    {examForm.openTreatment && (
                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2">
                        <div>
                          <label className="block text-slate-600 font-medium mb-1">Chẩn Đoán Bệnh *</label>
                          <select
                            value={examForm.maBenh}
                            onChange={(e) => setExamForm({ ...examForm, maBenh: e.target.value })}
                            className="w-full p-1.5 border border-slate-200 rounded-lg bg-white"
                          >
                            <option value="">-- Chọn bệnh --</option>
                            {diseases.map((dis) => (
                              <option key={dis.maBenh} value={dis.maBenh}>
                                {dis.maBenh} - {dis.tenBenh}
                              </option>
                            ))}
                          </select>
                        </div>

                        <div>
                          <label className="block text-slate-600 font-medium mb-1">Mức Độ Nặng</label>
                          <select
                            value={examForm.mucDoNang}
                            onChange={(e) => setExamForm({ ...examForm, mucDoNang: e.target.value })}
                            className="w-full p-1.5 border border-slate-200 rounded-lg bg-white"
                          >
                            <option value="Nhe">Nhẹ</option>
                            <option value="Vua">Vừa</option>
                            <option value="Nang">Nặng</option>
                          </select>
                        </div>

                        <div>
                          <label className="block text-slate-600 font-medium mb-1">Bố Trí Giường Bệnh</label>
                          <select
                            value={examForm.maGiuong}
                            onChange={(e) => setExamForm({ ...examForm, maGiuong: e.target.value })}
                            className="w-full p-1.5 border border-slate-200 rounded-lg bg-white"
                          >
                            <option value="">-- Điều trị ngoại trú --</option>
                            {availableBeds.map((bed) => (
                              <option key={bed.maGiuong} value={bed.maGiuong}>
                                Giường {bed.maGiuong} (Phòng: {bed.maPhong})
                              </option>
                            ))}
                          </select>
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="border-t border-slate-100 pt-3 flex justify-end">
                    <button
                      type="submit"
                      className="px-5 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-lg font-bold shadow-md transition"
                    >
                      Lưu Hồ Sơ Khám & Xuất Hóa Đơn Trực Tiếp
                    </button>
                  </div>
                </form>
              </div>

              {/* Form Kê Đơn Thuốc Thực Tế */}
              <div className="bg-white rounded-xl border border-slate-200/80 p-6 shadow-xs space-y-4">
                <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <Pill className="w-4 h-4 text-teal-600" />
                  Kê Đơn Thuốc (SuDungThuoc)
                </h2>
                <p className="text-[11px] text-slate-500">
                  Trigger CSDL kiểm tra số lượng và trừ trực tiếp vào tồn kho bảng Thuoc.
                </p>

                <form onSubmit={handlePrescribeMedicine} className="space-y-3 text-xs">
                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Mã Sự Kiện Y Tế *</label>
                    <select
                      value={rxForm.maSuKien}
                      onChange={(e) => setRxForm({ ...rxForm, maSuKien: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 font-mono"
                      required
                    >
                      <option value="">-- Chọn sự kiện y tế --</option>
                      {events.map((ev) => (
                        <option key={ev.maSuKien} value={ev.maSuKien}>
                          {ev.maSuKien} ({ev.loaiSuKien}) - BN: {ev.maBN}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Chọn Thuốc Trong Kho *</label>
                    <select
                      value={rxForm.maThuoc}
                      onChange={(e) => setRxForm({ ...rxForm, maThuoc: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                      required
                    >
                      <option value="">-- Chọn thuốc --</option>
                      {medicines.map((m) => (
                        <option key={m.maThuoc} value={m.maThuoc}>
                          {m.tenThuoc} (Còn: {m.tonKho} {m.donViTinh} - {formatVND(m.donGia)})
                        </option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="block text-slate-600 font-medium mb-1">Số Lượng Kê Đơn *</label>
                    <input
                      type="number"
                      min={1}
                      value={rxForm.soLuong}
                      onChange={(e) => setRxForm({ ...rxForm, soLuong: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 font-bold"
                      required
                    />
                  </div>

                  <button
                    type="submit"
                    className="w-full py-2.5 bg-slate-800 text-white rounded-lg font-semibold hover:bg-slate-900 shadow-md transition"
                  >
                    + Xác Nhận Kê Đơn & Trừ Tồn Kho
                  </button>
                </form>
              </div>
            </div>
          )}

          {/* TAB 4: TREATMENT COURSES & BEDS */}
          {activeTab === 'treatment' && (
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <p className="text-xs text-slate-500">
                  Quản lý các đợt điều trị (bảng dotdieutri), giải phóng giường bệnh và ghi nhận các lần chữa bệnh
                </p>
              </div>

              <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                    <tr>
                      <th className="p-3.5">Mã Đợt</th>
                      <th className="p-3.5">Mã Sự Kiện Khám</th>
                      <th className="p-3.5">Mã Bệnh</th>
                      <th className="p-3.5">Mức Độ</th>
                      <th className="p-3.5">Giường Bệnh</th>
                      <th className="p-3.5">Ngày Bắt Đầu</th>
                      <th className="p-3.5">Trạng Thái</th>
                      <th className="p-3.5 text-right">Thao Tác</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-slate-700">
                    {treatmentCourses.map((tc) => (
                      <tr key={tc.maDotDieuTri} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3.5 font-mono font-bold text-teal-700">{tc.maDotDieuTri}</td>
                        <td className="p-3.5 font-mono text-slate-600">{tc.maSuKienKham}</td>
                        <td className="p-3.5 font-semibold text-slate-800">{tc.maBenh}</td>
                        <td className="p-3.5">
                          <span className={`px-2 py-0.5 rounded text-[10px] font-semibold ${
                            tc.mucDoNang === 'Nang' ? 'bg-red-50 text-red-700' : tc.mucDoNang === 'Vua' ? 'bg-amber-50 text-amber-700' : 'bg-slate-100 text-slate-700'
                          }`}>
                            {tc.mucDoNang}
                          </span>
                        </td>
                        <td className="p-3.5 font-mono text-slate-600">{tc.maGiuong || 'Ngoại trú'}</td>
                        <td className="p-3.5">{tc.ngayBatDau}</td>
                        <td className="p-3.5">
                          <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold ${
                            tc.trangThai === 'DangDieuTri' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                          }`}>
                            {tc.trangThai === 'DangDieuTri' ? 'Đang điều trị' : 'Đã khỏi'}
                          </span>
                        </td>
                        <td className="p-3.5 text-right">
                          {tc.trangThai === 'DangDieuTri' && (
                            <button
                              onClick={() => handleCloseTreatment(tc.maDotDieuTri)}
                              className="px-2.5 py-1 bg-emerald-600 text-white rounded text-[11px] font-medium hover:bg-emerald-700 transition"
                            >
                              Kết luận khỏi bệnh
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 5: PHARMACY INVENTORY */}
          {activeTab === 'pharmacy' && (
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <p className="text-xs text-slate-500">Danh mục thuốc & kiểm soát tồn kho tự động trong CSDL (bảng thuoc)</p>
              </div>

              <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                    <tr>
                      <th className="p-3.5">Mã Thuốc</th>
                      <th className="p-3.5">Tên Thuốc</th>
                      <th className="p-3.5">Hãng Sản Xuất</th>
                      <th className="p-3.5">Đơn Vị Tính</th>
                      <th className="p-3.5">Đơn Giá</th>
                      <th className="p-3.5">Tồn Kho</th>
                      <th className="p-3.5">Tình Trạng</th>
                      <th className="p-3.5 text-right">Thao Tác</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-slate-700">
                    {medicines.map((m) => (
                      <tr key={m.maThuoc} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3.5 font-mono font-bold text-teal-700">{m.maThuoc}</td>
                        <td className="p-3.5 font-medium text-slate-900">{m.tenThuoc}</td>
                        <td className="p-3.5">{m.hangSX || 'Việt Nam'}</td>
                        <td className="p-3.5">{m.donViTinh}</td>
                        <td className="p-3.5 font-semibold text-slate-800">{formatVND(m.donGia)}</td>
                        <td className="p-3.5 font-bold">{m.tonKho}</td>
                        <td className="p-3.5">
                          {m.tonKho < 200 ? (
                            <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-rose-600 bg-rose-50 px-2 py-0.5 rounded">
                              <AlertCircle className="w-3 h-3" /> Cần nhập thêm
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                              <CheckCircle2 className="w-3 h-3" /> Đầy đủ
                            </span>
                          )}
                        </td>
                        <td className="p-3.5 text-right">
                          <button
                            onClick={() => {
                              setSelectedMedForRestock(m);
                              setShowRestockModal(true);
                            }}
                            className="px-2.5 py-1 bg-slate-800 text-white rounded text-[11px] font-medium hover:bg-slate-900 transition"
                          >
                            + Nhập kho
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 6: BILLING & INVOICES */}
          {activeTab === 'billing' && (
            <div className="space-y-5">
              <div className="flex justify-between items-center">
                <p className="text-xs text-slate-500">Quản lý và thu phí viện phí trực tiếp trong CSDL (bảng hoadon)</p>
              </div>

              <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                    <tr>
                      <th className="p-3.5">Mã Sự Kiện</th>
                      <th className="p-3.5">Ngày Lập Hóa Đơn</th>
                      <th className="p-3.5">Tổng Tiền Viện Phí</th>
                      <th className="p-3.5">Trạng Thái Thu Phí</th>
                      <th className="p-3.5 text-right">Hành Động</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-slate-700">
                    {invoices.map((inv) => (
                      <tr key={inv.maSuKien} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3.5 font-mono font-bold text-teal-700">{inv.maSuKien}</td>
                        <td className="p-3.5">{inv.ngayLap?.replace('T', ' ')?.slice(0, 19) || '---'}</td>
                        <td className="p-3.5 font-bold text-slate-900">{formatVND(inv.tongTien)}</td>
                        <td className="p-3.5">
                          <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold ${
                            inv.trangThaiTT === 'DaThanhToan' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-amber-50 text-amber-700 border border-amber-200'
                          }`}>
                            {inv.trangThaiTT === 'DaThanhToan' ? 'Đã Thanh Toán' : 'Chưa Thanh Toán'}
                          </span>
                        </td>
                        <td className="p-3.5 text-right">
                          {inv.trangThaiTT !== 'DaThanhToan' && (
                            <button
                              onClick={() => handlePayInvoice(inv.maSuKien)}
                              className="px-3 py-1 bg-teal-600 text-white rounded text-[11px] font-semibold hover:bg-teal-700 transition shadow-xs"
                            >
                              Xác Nhận Thu Phí
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 7: MASTER DATA CRUD (Mục 1) */}
          {activeTab === 'master' && (
            <div className="space-y-6">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                  <h2 className="text-sm font-bold text-slate-800">Quản Lý Dữ Liệu Danh Mục (Master Data)</h2>
                  <p className="text-xs text-slate-500">Quản lý Bác sĩ, Y tá, Danh mục bệnh, Thiết bị y tế, Dịch vụ, Phòng khám, Giường bệnh chuẩn CSDL</p>
                </div>
                <button
                  onClick={() => {
                    setMasterForm({});
                    setShowAddMasterModal(true);
                  }}
                  className="px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 flex items-center gap-1.5 shadow-sm transition"
                >
                  <Plus className="w-4 h-4" /> Thêm Mới Dữ Liệu
                </button>
              </div>

              {/* Subtabs Master Data */}
              <div className="flex flex-wrap gap-2 border-b border-slate-200 pb-2">
                {[
                  { id: 'bac-sy', label: 'Bác Sĩ (BacSy)', count: doctors.length },
                  { id: 'y-ta', label: 'Y Tá (YTa)', count: masterNurses.length },
                  { id: 'danh-muc-benh', label: 'Danh Mục Bệnh', count: diseases.length },
                  { id: 'thiet-bi', label: 'Thiết Bị Y Tế', count: masterDevices.length },
                  { id: 'dich-vu', label: 'Dịch Vụ Y Tế', count: masterServices.length },
                  { id: 'phong-kham', label: 'Phòng Khám', count: masterRooms.length },
                  { id: 'giuong-benh', label: 'Giường Bệnh', count: masterBeds.length },
                ].map((st) => (
                  <button
                    key={st.id}
                    onClick={() => setMasterTab(st.id)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                      masterTab === st.id
                        ? 'bg-slate-900 text-white shadow-xs'
                        : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    {st.label} ({st.count})
                  </button>
                ))}
              </div>

              {/* Bảng Bác Sĩ */}
              {masterTab === 'bac-sy' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Bác Sĩ</th>
                        <th className="p-3.5">Chuyên Môn</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {doctors.map((d) => (
                        <tr key={d.maBS} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{d.maBS}</td>
                          <td className="p-3.5 font-medium">{d.chuyenMon || 'Bác sĩ chuyên khoa'}</td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('bac-sy', d.maBS)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Y Tá */}
              {masterTab === 'y-ta' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Y Tá</th>
                        <th className="p-3.5">Trình Độ</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {masterNurses.map((n) => (
                        <tr key={n.maYTa} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{n.maYTa}</td>
                          <td className="p-3.5 font-medium">{n.trinhDo || 'Cử nhân điều dưỡng'}</td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('y-ta', n.maYTa)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Danh Mục Bệnh */}
              {masterTab === 'danh-muc-benh' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Bệnh</th>
                        <th className="p-3.5">Tên Bệnh Lý</th>
                        <th className="p-3.5">Khoa Điều Trị</th>
                        <th className="p-3.5">Mô Tả Bệnh</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {diseases.map((dis) => (
                        <tr key={dis.maBenh} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{dis.maBenh}</td>
                          <td className="p-3.5 font-bold text-slate-900">{dis.tenBenh}</td>
                          <td className="p-3.5 font-medium text-slate-600">{dis.maKhoa || '---'}</td>
                          <td className="p-3.5 text-slate-500">{dis.moTa || '---'}</td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('danh-muc-benh', dis.maBenh)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Thiết Bị Y Tế */}
              {masterTab === 'thiet-bi' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Thiết Bị</th>
                        <th className="p-3.5">Tên Thiết Bị</th>
                        <th className="p-3.5">Khoa Phụ Trách</th>
                        <th className="p-3.5">Tình Trạng</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {masterDevices.map((tb) => (
                        <tr key={tb.maTB} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{tb.maTB}</td>
                          <td className="p-3.5 font-bold text-slate-900">{tb.tenTB}</td>
                          <td className="p-3.5 text-slate-600">{tb.maKhoa || 'Chung'}</td>
                          <td className="p-3.5">
                            <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-700 font-semibold text-[10px]">
                              {tb.tinhTrang || 'Hoạt động tốt'}
                            </span>
                          </td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('thiet-bi', tb.maTB)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Dịch Vụ Y Tế */}
              {masterTab === 'dich-vu' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Dịch Vụ</th>
                        <th className="p-3.5">Tên Dịch Vụ</th>
                        <th className="p-3.5">Đơn Giá Viện Phí</th>
                        <th className="p-3.5">Mô Tả Kỹ Thuật</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {masterServices.map((dv) => (
                        <tr key={dv.maDV} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{dv.maDV}</td>
                          <td className="p-3.5 font-bold text-slate-900">{dv.tenDV}</td>
                          <td className="p-3.5 font-semibold text-emerald-700">{formatVND(dv.donGia)}</td>
                          <td className="p-3.5 text-slate-500">{dv.moTa || '---'}</td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('dich-vu', dv.maDV)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Phòng Khám */}
              {masterTab === 'phong-kham' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Phòng</th>
                        <th className="p-3.5">Tên Phòng Khám</th>
                        <th className="p-3.5">Khoa Trực Thuộc</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {masterRooms.map((r) => (
                        <tr key={r.maPhong} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{r.maPhong}</td>
                          <td className="p-3.5 font-bold text-slate-900">{r.tenPhong}</td>
                          <td className="p-3.5 text-slate-600">{r.maKhoa}</td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('phong-kham', r.maPhong)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

              {/* Bảng Giường Bệnh */}
              {masterTab === 'giuong-benh' && (
                <div className="bg-white rounded-xl border border-slate-200/80 overflow-hidden shadow-xs">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50/80 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3.5">Mã Giường</th>
                        <th className="p-3.5">Phòng Khám</th>
                        <th className="p-3.5">Trạng Thái Giường</th>
                        <th className="p-3.5 text-right">Thao Tác</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {masterBeds.map((b) => (
                        <tr key={b.maGiuong} className="hover:bg-slate-50/80">
                          <td className="p-3.5 font-mono font-bold text-teal-700">{b.maGiuong}</td>
                          <td className="p-3.5 font-medium">{b.maPhong}</td>
                          <td className="p-3.5">
                            <span className={`px-2 py-0.5 rounded font-semibold text-[10px] ${
                              b.trangThai === 'Trong' ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'
                            }`}>
                              {b.trangThai === 'Trong' ? 'Trống' : 'Đang sử dụng'}
                            </span>
                          </td>
                          <td className="p-3.5 text-right">
                            <button
                              onClick={() => handleDeleteMasterData('giuong-benh', b.maGiuong)}
                              className="text-rose-600 hover:bg-rose-50 p-1.5 rounded transition"
                              title="Xóa"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}

          {/* TAB 8: ADVANCED REPORTS (Mục 2.1, 2.2, 3) */}
          {activeTab === 'reports' && (
            <div className="space-y-6">
              {/* Header Lọc Theo Tháng */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 rounded-xl border border-slate-200/80 shadow-xs">
                <div>
                  <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <BarChart3 className="w-4 h-4 text-teal-600" />
                    Báo Cáo Nghiệp Vụ Chuyên Sâu (Đề Tài 4)
                  </h2>
                  <p className="text-xs text-slate-500">Phân rã doanh thu 5 nguồn, xếp hạng bệnh lý và tính lương bác sĩ/y tá chuẩn nghiệp vụ</p>
                </div>
                <div className="flex items-center gap-3">
                  <label className="text-xs font-semibold text-slate-700">Chọn Tháng/Năm:</label>
                  <input
                    type="month"
                    value={selectedMonth}
                    onChange={(e) => setSelectedMonth(e.target.value)}
                    className="p-1.5 border border-slate-200 rounded-lg text-xs font-mono bg-slate-50"
                  />
                  <button
                    onClick={() => fetchMonthlyReports(selectedMonth)}
                    className="px-3 py-1.5 bg-teal-600 text-white rounded-lg text-xs font-semibold hover:bg-teal-700 transition"
                  >
                    Xem Báo Cáo
                  </button>
                </div>
              </div>

              {/* MỤC 2.2: PHÂN RÃ DOANH THU 5 NGUỒN */}
              <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-xs space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <DollarSign className="w-4 h-4 text-emerald-600" />
                    Mục 2.2: Doanh Thu Phòng Khám Phân Rã Theo 5 Nguồn Thu ({selectedMonth})
                  </h3>
                  <span className="text-xs font-bold text-emerald-700 bg-emerald-50 px-3 py-1 rounded-full border border-emerald-200">
                    Tổng: {formatVND(detailedRevenue.TongDoanhThu || 0)}
                  </span>
                </div>

                <div className="grid grid-cols-2 sm:grid-cols-5 gap-3 pt-2">
                  <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                    <span className="text-[10px] uppercase font-bold text-slate-500 block">1. Tiền Khám</span>
                    <span className="text-sm font-extrabold text-slate-900">{formatVND(detailedRevenue.TienKhamBenh || detailedRevenue.TienKham || 0)}</span>
                  </div>
                  <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                    <span className="text-[10px] uppercase font-bold text-slate-500 block">2. Tiền Chữa</span>
                    <span className="text-sm font-extrabold text-slate-900">{formatVND(detailedRevenue.TienChuaBenh || detailedRevenue.TienChua || 0)}</span>
                  </div>
                  <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                    <span className="text-[10px] uppercase font-bold text-slate-500 block">3. Tiền Thuốc</span>
                    <span className="text-sm font-extrabold text-slate-900">{formatVND(detailedRevenue.TienThuoc || 0)}</span>
                  </div>
                  <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                    <span className="text-[10px] uppercase font-bold text-slate-500 block">4. Tiền Dịch Vụ</span>
                    <span className="text-sm font-extrabold text-slate-900">{formatVND(detailedRevenue.TienDichVu || 0)}</span>
                  </div>
                  <div className="bg-slate-50 p-3 rounded-lg border border-slate-200">
                    <span className="text-[10px] uppercase font-bold text-slate-500 block">5. Giường / CSVC</span>
                    <span className="text-sm font-extrabold text-slate-900">{formatVND(detailedRevenue.TienThietBiGiuong || detailedRevenue.TienGiuongThietBi || 0)}</span>
                  </div>
                </div>
              </div>

              {/* MỤC 2.1: BÁO CÁO BỆNH LÝ MẮC PHẢI TRONG THÁNG */}
              <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-xs space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <TrendingUp className="w-4 h-4 text-teal-600" />
                    Mục 2.1: Thống Kê Các Loại Bệnh Mắc Phải (Sắp xếp giảm dần số ca, tính tái phát)
                  </h3>
                  <span className="text-xs text-slate-400">Chuỗi khám chữa liên tiếp = 1 đợt</span>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3">Hạng</th>
                        <th className="p-3">Mã Bệnh</th>
                        <th className="p-3">Tên Bệnh Lý</th>
                        <th className="p-3">Khoa Phụ Trách</th>
                        <th className="p-3 text-center">Tổng Số Ca Mắc</th>
                        <th className="p-3 text-center">Số Bệnh Nhân</th>
                        <th className="p-3 text-center">Đợt Mới</th>
                        <th className="p-3 text-center">Đợt Tái Phát</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {monthlyDiseases.length === 0 ? (
                        <tr>
                          <td colSpan={8} className="p-4 text-center text-slate-400">
                            Không có dữ liệu bệnh lý phát sinh trong tháng {selectedMonth}.
                          </td>
                        </tr>
                      ) : (
                        monthlyDiseases.map((b, idx) => (
                          <tr key={b.maBenh} className="hover:bg-slate-50/80">
                            <td className="p-3 font-bold text-slate-400">#{idx + 1}</td>
                            <td className="p-3 font-mono font-bold text-teal-700">{b.maBenh}</td>
                            <td className="p-3 font-semibold text-slate-900">{b.tenBenh}</td>
                            <td className="p-3 text-slate-600">{b.nhomBenh || b.khoa || 'Chuyên khoa'}</td>
                            <td className="p-3 text-center font-bold text-rose-600">{b.soCaMac}</td>
                            <td className="p-3 text-center font-medium">{b.soBenhNhanDuyNhat || b.soBenhNhan || 0}</td>
                            <td className="p-3 text-center text-emerald-600 font-medium">{b.soCaMac - (b.soCaTaiPhat || 0)}</td>
                            <td className="p-3 text-center text-amber-600 font-medium">{b.soCaTaiPhat || b.soDotTaiPhat || 0}</td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* MỤC 3: BẢNG LƯƠNG NHÂN SỰ CHUẨN ĐỀ TÀI 4 */}
              <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-xs space-y-4">
                <div>
                  <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                    <Award className="w-4 h-4 text-amber-600" />
                    Mục 3: Bảng Tính Lương Nhân Viên Y Tế (Tháng {selectedMonth})
                  </h3>
                  <p className="text-[11px] text-slate-500">
                    Quy tắc: Bác sĩ = Lương CB * Hệ số + (Số ca khỏi bệnh * 1.000.000đ); Y tá = Lương CB * Hệ số + (Số lượt hỗ trợ * 200.000đ).
                  </p>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead className="bg-slate-50 text-slate-500 border-b border-slate-200 font-semibold uppercase text-[10px]">
                      <tr>
                        <th className="p-3">Mã NV</th>
                        <th className="p-3">Họ Tên</th>
                        <th className="p-3">Vị Trí</th>
                        <th className="p-3">Chuyên Môn/Trình Độ</th>
                        <th className="p-3">Lương Cơ Bản</th>
                        <th className="p-3">Hệ Số</th>
                        <th className="p-3 text-center">Thành Tích Tháng</th>
                        <th className="p-3">Tiền Thưởng</th>
                        <th className="p-3 text-right">Tổng Thực Lĩnh</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-slate-700">
                      {detailedSalaries.length === 0 ? (
                        <tr>
                          <td colSpan={9} className="p-4 text-center text-slate-400">
                            Chưa có dữ liệu bảng lương tháng {selectedMonth}.
                          </td>
                        </tr>
                      ) : (
                        detailedSalaries.map((s) => (
                          <tr key={s.maNV} className="hover:bg-slate-50/80">
                            <td className="p-3 font-mono font-bold text-teal-700">{s.maNV}</td>
                            <td className="p-3 font-bold text-slate-900">{s.hoTen}</td>
                            <td className="p-3">
                              <span className={`px-2 py-0.5 rounded text-[10px] font-semibold ${
                                s.loaiNV === 'Bác sĩ' ? 'bg-indigo-50 text-indigo-700' : 'bg-pink-50 text-pink-700'
                              }`}>
                                {s.loaiNV}
                              </span>
                            </td>
                            <td className="p-3 text-slate-600">{s.chuyenMon || s.trinhDo || '---'}</td>
                            <td className="p-3">{formatVND(s.luongCoBan)}</td>
                            <td className="p-3 font-mono">{s.heSoLuong}</td>
                            <td className="p-3 text-center font-bold text-teal-700">
                              {s.loaiNV === 'Bác sĩ' ? `${s.soCaKhoiBenh} ca khỏi` : `${s.soLuotHoTro} lượt HT`}
                            </td>
                            <td className="p-3 font-medium text-emerald-600">{formatVND(s.tienThuong)}</td>
                            <td className="p-3 text-right font-extrabold text-slate-900">{formatVND(s.tongLuong)}</td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* MODAL HỒ SƠ BỆNH NHÂN 360° (Mục 1.b) */}
      {showHoSoModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-4xl w-full max-h-[90vh] flex flex-col shadow-2xl animate-in fade-in zoom-in duration-150 overflow-hidden">
            {/* Modal Header */}
            <div className="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-900 text-white">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-lg bg-teal-500 flex items-center justify-center">
                  <UserCheck className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="font-bold text-sm tracking-tight">HỒ SƠ BỆNH ÁN 360° TOÀN DIỆN (MỤC 1.B)</h3>
                  <p className="text-[11px] text-teal-300">Tình trạng bệnh hiện tại, bác sĩ phụ trách, giường nằm & toàn bộ viện phí</p>
                </div>
              </div>
              <button
                onClick={() => setShowHoSoModal(false)}
                className="text-slate-400 hover:text-white text-lg font-bold"
              >
                ✕
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6 overflow-y-auto space-y-6 text-xs flex-1">
              {hoSoLoading ? (
                <div className="py-12 text-center text-slate-400 flex flex-col items-center gap-2">
                  <RefreshCw className="w-6 h-6 animate-spin text-teal-600" />
                  Đang truy xuất hồ sơ 360° từ CSDL PostgreSQL...
                </div>
              ) : hoSoData ? (
                <>
                  {/* Thông tin hành chính */}
                  <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <span className="text-[10px] text-slate-400 uppercase block font-semibold">Mã Bệnh Nhân</span>
                      <span className="font-mono font-bold text-teal-700 text-sm">{hoSoData.benhNhan?.maBN}</span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 uppercase block font-semibold">Họ Và Tên</span>
                      <span className="font-bold text-slate-900 text-sm">{hoSoData.benhNhan?.hoTen}</span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 uppercase block font-semibold">Giới Tính / Ngày Sinh</span>
                      <span className="font-medium text-slate-700">
                        {hoSoData.benhNhan?.gioiTinh === 'M' ? 'Nam' : 'Nữ'} • {hoSoData.benhNhan?.ngaySinh || '---'}
                      </span>
                    </div>
                    <div>
                      <span className="text-[10px] text-slate-400 uppercase block font-semibold">CCCD / SĐT</span>
                      <span className="font-mono text-slate-700">{hoSoData.benhNhan?.soCCCD} • {hoSoData.benhNhan?.sdt}</span>
                    </div>
                  </div>

                  {/* 1. TÌNH TRẠNG BỆNH HIỆN TẠI (Đang điều trị) */}
                  <div className="space-y-3">
                    <h4 className="font-bold text-slate-900 flex items-center gap-2 text-xs uppercase tracking-wider text-teal-800">
                      <HeartHandshake className="w-4 h-4 text-teal-600" />
                      1. Tình Trạng Bệnh Đang Điều Trị Hiện Tại
                    </h4>

                    {hoSoData.benhHienTai?.length === 0 ? (
                      <p className="p-3 bg-emerald-50 text-emerald-700 rounded-lg border border-emerald-200">
                        Bệnh nhân hiện tại không có đợt điều trị nội trú hay ngoại trú nào đang mở (đã khỏi bệnh).
                      </p>
                    ) : (
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {hoSoData.benhHienTai?.map((bh) => (
                          <div key={bh.maDotDieuTri} className="bg-white border-2 border-teal-500/30 rounded-xl p-4 space-y-2 shadow-xs">
                            <div className="flex justify-between items-start">
                              <div>
                                <span className="font-extrabold text-sm text-slate-900">{bh.tenBenh || bh.maBenh}</span>
                                <span className="text-[10px] text-slate-400 block font-mono">Đợt: {bh.maDotDieuTri}</span>
                              </div>
                              <span className="px-2 py-0.5 rounded-full bg-blue-50 text-blue-700 font-bold text-[10px]">
                                Đang điều trị
                              </span>
                            </div>
                            <div className="divide-y divide-slate-100 text-[11px] pt-1">
                              <div className="py-1 flex justify-between">
                                <span className="text-slate-500">Số lần khám/chữa cho bệnh này:</span>
                                <span className="font-bold text-teal-700">Lần thứ {bh.soLanKhamChuaHienTai}</span>
                              </div>
                              <div className="py-1 flex justify-between">
                                <span className="text-slate-500">Bác sĩ phụ trách chính:</span>
                                <span className="font-medium text-slate-800">{bh.bacSyPhuTrach}</span>
                              </div>
                              <div className="py-1 flex justify-between">
                                <span className="text-slate-500">Giường bố trí:</span>
                                <span className="font-mono font-semibold text-slate-800">{bh.maGiuong || 'Ngoại trú'}</span>
                              </div>
                              <div className="py-1 flex justify-between">
                                <span className="text-slate-500">Mức độ bệnh:</span>
                                <span className="font-semibold text-amber-600">{bh.mucDoNang}</span>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* 2. TOÀN BỘ LỊCH SỬ KHÁM CHỮA & CHI PHÍ CHI TIẾT */}
                  <div className="space-y-3">
                    <h4 className="font-bold text-slate-900 flex items-center gap-2 text-xs uppercase tracking-wider text-teal-800">
                      <Clock className="w-4 h-4 text-teal-600" />
                      2. Toàn Bộ Lịch Sử Khám/Chữa & Chi Tiết Viện Phí Từng Khoản Mục
                    </h4>

                    {hoSoData.lichSuChiTiet?.length === 0 ? (
                      <p className="text-slate-400 py-3">Chưa có lịch sử khám chữa bệnh nào.</p>
                    ) : (
                      <div className="space-y-4">
                        {hoSoData.lichSuChiTiet?.map((sk) => (
                          <div key={sk.maSuKien} className="bg-slate-50 rounded-xl border border-slate-200 p-4 space-y-3">
                            <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-200/80 pb-2">
                              <div className="flex items-center gap-2">
                                <span className="font-mono font-bold text-slate-800 bg-white px-2 py-0.5 rounded border border-slate-200">
                                  {sk.maSuKien}
                                </span>
                                <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                                  sk.loaiSuKien === 'Kham' ? 'bg-indigo-100 text-indigo-700' : 'bg-emerald-100 text-emerald-700'
                                }`}>
                                  {sk.loaiSuKien === 'Kham' ? 'Lần Khám' : 'Lần Chữa Bệnh'}
                                </span>
                                <span className="text-slate-500">Bác sĩ: {sk.maBS}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <span className="text-slate-400 font-mono">{sk.thoiGian?.replace('T', ' ')?.slice(0, 19)}</span>
                                <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                                  sk.trangThaiTT === 'DaThanhToan' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                                }`}>
                                  {sk.trangThaiTT === 'DaThanhToan' ? 'Đã Thanh Toán' : 'Chưa Thanh Toán'}
                                </span>
                              </div>
                            </div>

                            {/* Bảng kê chi phí chi tiết */}
                            <div>
                              <span className="text-[10px] uppercase font-bold text-slate-500 block mb-1">Chi tiết các khoản mục thanh toán (HoaDonChiTiet):</span>
                              <table className="w-full text-left text-[11px] bg-white rounded border border-slate-200">
                                <thead className="bg-slate-100 text-slate-600 font-semibold">
                                  <tr>
                                    <th className="p-2">Dòng</th>
                                    <th className="p-2">Nội Dung Khoản Mục</th>
                                    <th className="p-2">Số Lượng</th>
                                    <th className="p-2">Đơn Giá</th>
                                    <th className="p-2 text-right">Thành Tiền</th>
                                  </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-100">
                                  {sk.cacKhoanChiPhi?.map((cp) => (
                                    <tr key={cp.soDong}>
                                      <td className="p-2 font-mono text-slate-400">#{cp.soDong}</td>
                                      <td className="p-2 font-medium text-slate-800">{cp.moTaKhoanMuc || cp.noiDung}</td>
                                      <td className="p-2">{cp.soLuong || 1}</td>
                                      <td className="p-2">{formatVND(cp.donGia || (cp.soTien ? (cp.soTien / (cp.soLuong || 1)) : 0))}</td>
                                      <td className="p-2 text-right font-bold text-slate-900">{formatVND(cp.soTien || cp.thanhTien)}</td>
                                    </tr>
                                  ))}
                                  <tr className="bg-slate-50 font-bold">
                                    <td colSpan={4} className="p-2 text-right text-slate-700">Tổng Viện Phí Sự Kiện:</td>
                                    <td className="p-2 text-right text-teal-700 font-extrabold">{formatVND(sk.tongTien || sk.tongTienHoaDon || 0)}</td>
                                  </tr>
                                </tbody>
                              </table>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </>
              ) : null}
            </div>

            {/* Modal Footer */}
            <div className="p-4 border-t border-slate-100 flex justify-end bg-slate-50">
              <button
                onClick={() => setShowHoSoModal(false)}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white font-semibold rounded-lg text-xs transition"
              >
                Đóng Hồ Sơ
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL THÊM MỚI MASTER DATA (Mục 1) */}
      {showAddMasterModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <Database className="w-4 h-4 text-teal-600" />
                Thêm Mới: {
                  masterTab === 'bac-sy' ? 'Bác Sĩ' :
                  masterTab === 'y-ta' ? 'Y Tá' :
                  masterTab === 'danh-muc-benh' ? 'Danh Mục Bệnh' :
                  masterTab === 'thiet-bi' ? 'Thiết Bị Y Tế' :
                  masterTab === 'dich-vu' ? 'Dịch Vụ Y Tế' :
                  masterTab === 'phong-kham' ? 'Phòng Khám' : 'Giường Bệnh'
                }
              </h3>
              <button onClick={() => setShowAddMasterModal(false)} className="text-slate-400 hover:text-slate-600">✕</button>
            </div>

            <form onSubmit={handleAddMasterData} className="space-y-3 text-xs">
              {masterTab === 'bac-sy' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Bác Sĩ (ví dụ: BS004) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maBS || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maBS: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Chuyên Môn</label>
                    <input
                      type="text"
                      placeholder="Nội khoa, Ngoại khoa, Nhi khoa..."
                      value={masterForm.chuyenMon || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, chuyenMon: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                </>
              )}

              {masterTab === 'y-ta' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Y Tá (ví dụ: YT004) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maYTa || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maYTa: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Trình Độ</label>
                    <input
                      type="text"
                      placeholder="Cao đẳng, Cử nhân điều dưỡng..."
                      value={masterForm.trinhDo || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, trinhDo: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                </>
              )}

              {masterTab === 'danh-muc-benh' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Bệnh (ví dụ: B004) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maBenh || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maBenh: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Tên Bệnh Lý *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.tenBenh || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, tenBenh: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Khoa Phụ Trách</label>
                    <select
                      value={masterForm.maKhoa || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maKhoa: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    >
                      <option value="">-- Chọn khoa --</option>
                      {departments.map((d) => (
                        <option key={d.maKhoa} value={d.maKhoa}>{d.tenKhoa}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mô Tả</label>
                    <textarea
                      rows={2}
                      value={masterForm.moTa || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, moTa: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                </>
              )}

              {masterTab === 'thiet-bi' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Thiết Bị (ví dụ: TB004) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maTB || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maTB: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Tên Thiết Bị *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.tenTB || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, tenTB: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Khoa Trực Thuộc</label>
                    <select
                      value={masterForm.maKhoa || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maKhoa: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    >
                      <option value="">-- Chọn khoa --</option>
                      {departments.map((d) => (
                        <option key={d.maKhoa} value={d.maKhoa}>{d.tenKhoa}</option>
                      ))}
                    </select>
                  </div>
                </>
              )}

              {masterTab === 'dich-vu' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Dịch Vụ (ví dụ: DV004) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maDV || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maDV: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Tên Dịch Vụ *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.tenDV || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, tenDV: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Đơn Giá Viện Phí (VND) *</label>
                    <input
                      type="number"
                      required
                      value={masterForm.donGia || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, donGia: parseFloat(e.target.value) })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 font-bold"
                    />
                  </div>
                </>
              )}

              {masterTab === 'phong-kham' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Phòng (ví dụ: P104) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maPhong || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maPhong: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Tên Phòng Khám *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.tenPhong || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, tenPhong: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Khoa Phụ Trách</label>
                    <select
                      value={masterForm.maKhoa || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maKhoa: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                      required
                    >
                      <option value="">-- Chọn khoa --</option>
                      {departments.map((d) => (
                        <option key={d.maKhoa} value={d.maKhoa}>{d.tenKhoa}</option>
                      ))}
                    </select>
                  </div>
                </>
              )}

              {masterTab === 'giuong-benh' && (
                <>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Mã Giường (ví dụ: G105) *</label>
                    <input
                      type="text"
                      required
                      value={masterForm.maGiuong || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maGiuong: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                    />
                  </div>
                  <div>
                    <label className="block text-slate-700 font-medium mb-1">Phòng Khám *</label>
                    <select
                      value={masterForm.maPhong || ''}
                      onChange={(e) => setMasterForm({ ...masterForm, maPhong: e.target.value })}
                      className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                      required
                    >
                      <option value="">-- Chọn phòng --</option>
                      {rooms.map((r) => (
                        <option key={r.maPhong} value={r.maPhong}>{r.tenPhong}</option>
                      ))}
                    </select>
                  </div>
                </>
              )}

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowAddMasterModal(false)}
                  className="px-3.5 py-1.5 text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-1.5 bg-teal-600 text-white font-semibold rounded-lg hover:bg-teal-700"
                >
                  Lưu Vào CSDL
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL TIẾP NHẬN BỆNH NHÂN */}
      {showAddPatientModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4 animate-in fade-in zoom-in duration-150">
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <UserCheck className="w-4 h-4 text-teal-600" />
                Tiếp Nhận Bệnh Nhân Mới (Lưu CSDL)
              </h3>
              <button
                onClick={() => setShowAddPatientModal(false)}
                className="text-slate-400 hover:text-slate-600 text-lg font-bold"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAddPatient} className="space-y-3 text-xs">
              <div>
                <label className="block text-slate-700 font-medium mb-1">Họ và Tên *</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Hoàng Văn Nam"
                  value={newPatient.hoTen}
                  onChange={(e) => setNewPatient({ ...newPatient, hoTen: e.target.value })}
                  className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 focus:bg-white focus:ring-2 focus:ring-teal-500"
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-slate-700 font-medium mb-1">Giới Tính *</label>
                  <select
                    value={newPatient.gioiTinh}
                    onChange={(e) => setNewPatient({ ...newPatient, gioiTinh: e.target.value })}
                    className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                  >
                    <option value="M">Nam</option>
                    <option value="F">Nữ</option>
                  </select>
                </div>
                <div>
                  <label className="block text-slate-700 font-medium mb-1">Ngày Sinh</label>
                  <input
                    type="date"
                    value={newPatient.ngaySinh}
                    onChange={(e) => setNewPatient({ ...newPatient, ngaySinh: e.target.value })}
                    className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-slate-700 font-medium mb-1">Số CCCD (Duy nhất) *</label>
                  <input
                    type="text"
                    required
                    placeholder="12 số căn cước"
                    value={newPatient.soCCCD}
                    onChange={(e) => setNewPatient({ ...newPatient, soCCCD: e.target.value })}
                    className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                  />
                </div>
                <div>
                  <label className="block text-slate-700 font-medium mb-1">Số Điện Thoại</label>
                  <input
                    type="text"
                    placeholder="09..."
                    value={newPatient.sdt}
                    onChange={(e) => setNewPatient({ ...newPatient, sdt: e.target.value })}
                    className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                  />
                </div>
              </div>

              <div>
                <label className="block text-slate-700 font-medium mb-1">Địa Chỉ Thường Trú</label>
                <input
                  type="text"
                  placeholder="Quận/Huyện, Tỉnh/TP"
                  value={newPatient.diaChi}
                  onChange={(e) => setNewPatient({ ...newPatient, diaChi: e.target.value })}
                  className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50"
                />
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowAddPatientModal(false)}
                  className="px-3.5 py-2 text-slate-600 font-medium hover:bg-slate-100 rounded-lg"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-teal-600 text-white font-semibold rounded-lg hover:bg-teal-700 shadow-sm"
                >
                  Lưu Vào CSDL
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL NHẬP THÊM TỒN KHO THUỐC */}
      {showRestockModal && selectedMedForRestock && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl space-y-4">
            <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
              <PackagePlus className="w-4 h-4 text-teal-600" />
              Nhập Thêm Tồn Kho: {selectedMedForRestock.tenThuoc}
            </h3>
            <p className="text-xs text-slate-500">
              Hiện có: {selectedMedForRestock.tonKho} {selectedMedForRestock.donViTinh}
            </p>
            <div>
              <label className="block text-xs text-slate-700 font-medium mb-1">Số lượng nhập thêm</label>
              <input
                type="number"
                min={1}
                value={restockAmount}
                onChange={(e) => setRestockAmount(e.target.value)}
                className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 text-xs font-bold"
              />
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setShowRestockModal(false)}
                className="px-3 py-1.5 text-xs text-slate-600 hover:bg-slate-100 rounded-lg"
              >
                Hủy
              </button>
              <button
                onClick={handleRestock}
                className="px-4 py-1.5 text-xs bg-teal-600 text-white font-semibold rounded-lg hover:bg-teal-700"
              >
                Cập Nhật Kho
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Mobile Bottom Navigation Bar */}
      <div className="md:hidden fixed bottom-0 left-0 right-0 bg-slate-900 border-t border-slate-800 z-30 flex items-center justify-around py-2 px-1 shadow-2xl backdrop-blur-md bg-slate-900/95">
        <button
          onClick={() => setActiveTab('dashboard')}
          className={`flex flex-col items-center gap-1 py-1 px-2.5 rounded-lg text-[10px] font-medium transition ${
            activeTab === 'dashboard' ? 'text-teal-400 bg-slate-800 font-bold' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Activity className="w-4 h-4" />
          <span>Tổng quan</span>
        </button>
        <button
          onClick={() => setActiveTab('reception')}
          className={`flex flex-col items-center gap-1 py-1 px-2.5 rounded-lg text-[10px] font-medium transition ${
            activeTab === 'reception' ? 'text-teal-400 bg-slate-800 font-bold' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Users className="w-4 h-4" />
          <span>Bệnh nhân</span>
        </button>
        <button
          onClick={() => setActiveTab('examination')}
          className={`flex flex-col items-center gap-1 py-1 px-2.5 rounded-lg text-[10px] font-medium transition ${
            activeTab === 'examination' ? 'text-teal-400 bg-slate-800 font-bold' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Stethoscope className="w-4 h-4" />
          <span>Khám bệnh</span>
        </button>
        <button
          onClick={() => setActiveTab('billing')}
          className={`flex flex-col items-center gap-1 py-1 px-2.5 rounded-lg text-[10px] font-medium transition ${
            activeTab === 'billing' ? 'text-teal-400 bg-slate-800 font-bold' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Receipt className="w-4 h-4" />
          <span>Viện phí</span>
        </button>
        <button
          onClick={() => setMobileMenuOpen(true)}
          className="flex flex-col items-center gap-1 py-1 px-2.5 rounded-lg text-[10px] font-medium text-slate-400 hover:text-teal-400 transition"
        >
          <Menu className="w-4 h-4" />
          <span>Menu</span>
        </button>
      </div>
    </div>
  );
}
