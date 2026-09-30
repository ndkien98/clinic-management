import { useEffect, useRef, useState } from 'react';
import { Pill, X } from 'lucide-react';
import { clinicApi } from '../api/client';

const fields = [
  { name: 'maThuoc', label: 'Mã thuốc', maxLength: 10, required: true },
  { name: 'tenThuoc', label: 'Tên thuốc', maxLength: 150, required: true },
  { name: 'hangSX', label: 'Hãng sản xuất', maxLength: 100 },
  { name: 'donViTinh', label: 'Đơn vị tính', maxLength: 20 },
  { name: 'donGia', label: 'Đơn giá (VNĐ)', type: 'number', min: 0, max: 999999999999, step: 1, required: true },
  { name: 'tonKho', label: 'Số lượng tồn kho', type: 'number', min: 0, max: 2147483647, step: 1, required: true },
];

export default function AddMedicineModal({ medicines, onClose, onCreated }) {
  const [form, setForm] = useState({ maThuoc: '', tenThuoc: '', hangSX: '', donViTinh: '', donGia: '', tonKho: '0' });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const dialogRef = useRef(null);
  const submitting = useRef(false);

  useEffect(() => {
    const previousFocus = document.activeElement;
    dialogRef.current.showModal();
    return () => previousFocus?.focus();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();
    if (submitting.current) return;
    const data = Object.fromEntries(Object.entries(form).map(([key, value]) => [key, value.trim()]));
    if (!data.maThuoc || !data.tenThuoc) {
      setError('Vui lòng nhập mã thuốc và tên thuốc.');
      return;
    }
    if (medicines.some((medicine) => medicine.maThuoc === data.maThuoc)) {
      setError('Mã thuốc đã tồn tại. Vui lòng nhập mã khác.');
      return;
    }
    data.donGia = Number(data.donGia);
    data.tonKho = Number(data.tonKho);
    submitting.current = true;
    setSaving(true);
    setError('');
    try {
      const response = await clinicApi.createMedicine(data);
      onCreated(response.data);
    } catch (err) {
      setError(err.response?.data?.message || 'Không thể thêm dược phẩm. Vui lòng thử lại.');
    } finally {
      submitting.current = false;
      setSaving(false);
    }
  };

  return (
    <dialog ref={dialogRef} aria-labelledby="add-medicine-title"
      onCancel={(event) => { event.preventDefault(); if (!submitting.current) onClose(); }}
      className="w-[calc(100%-2rem)] max-w-lg max-h-[90vh] rounded-2xl p-6 shadow-2xl backdrop:bg-slate-900/50">
      <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
        <h3 id="add-medicine-title" className="flex items-center gap-2 text-sm font-bold text-slate-900">
          <Pill className="w-4 h-4 text-teal-600" /> Thêm dược phẩm mới
        </h3>
        <button type="button" aria-label="Đóng" disabled={saving} onClick={onClose} className="text-slate-400 hover:text-slate-600 disabled:opacity-50"><X className="w-5 h-5" /></button>
      </div>
      <form onSubmit={handleSubmit} className="space-y-4 text-xs">
        <p className="text-slate-500">Các trường có dấu * là bắt buộc.</p>
        <fieldset disabled={saving} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {fields.map(({ name, label, ...attributes }) => (
            <div key={name}>
              <label htmlFor={`medicine-${name}`} className="block text-slate-700 font-medium mb-1">{label}{attributes.required ? ' *' : ''}</label>
              <input id={`medicine-${name}`} name={name} type="text" {...attributes} autoFocus={name === 'maThuoc'}
                value={form[name]} onChange={(event) => setForm((previous) => ({ ...previous, [name]: event.target.value }))}
                className="w-full p-2 border border-slate-200 rounded-lg bg-slate-50 focus:outline-none focus:ring-2 focus:ring-teal-500 disabled:opacity-60" />
            </div>
          ))}
        </fieldset>
        {error && <p role="alert" className="text-rose-700 bg-rose-50 rounded-lg p-3">{error}</p>}
        <div className="flex justify-end gap-2 border-t border-slate-100 pt-4">
          <button type="button" disabled={saving} onClick={onClose} className="px-4 py-2 rounded-lg border border-slate-200 text-slate-600 disabled:opacity-50">Hủy</button>
          <button type="submit" disabled={saving} className="px-4 py-2 rounded-lg bg-teal-600 text-white font-semibold hover:bg-teal-700 disabled:opacity-50">{saving ? 'Đang lưu...' : 'Lưu dược phẩm'}</button>
        </div>
      </form>
    </dialog>
  );
}
