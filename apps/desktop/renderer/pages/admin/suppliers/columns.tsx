'use client';

import { ColumnDef } from '@tanstack/react-table';
import { ArrowUpDown, Edit2, MoreHorizontal, Trash2 } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { Button } from '../../../components/ui/button';
import { Checkbox } from '../../../components/ui/checkbox';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '../../../components/ui/dropdown-menu';

export type Supplier = {
  id: string;
  code: string;
  name: string;
  firstName?: string | null;
  lastName?: string | null;
  title?: string | null;
  taxId: string | null;
  address: string | null;
  provinceId?: number | null;
  districtId?: number | null;
  subdistrictId?: number | null;
  zipCode?: string | null;
  phone: string | null;
  email: string | null;
  avatar?: string | null;
  certificateNumber?: string | null;
  certificateExpire?: string | Date | null;
  score?: number | null;
  eudrQuotaUsed?: number | null;
  eudrQuotaCurrent?: number | null;
  notes?: string | null;
  rubberTypeCodes: string[];
  rubberTypeDetails: { code: string; name: string; category: string }[];
  province: {
    id?: number;
    name_th: string;
  } | null;
  status: string;
};

interface ColumnsProps {
  onEdit: (supplier: Supplier) => void;
  onDelete: (id: string) => void;
}

export const useSupplierColumns = ({ onEdit, onDelete }: ColumnsProps): ColumnDef<Supplier>[] => {
  const { t } = useTranslation();

  return [
    {
      id: 'select',
      header: ({ table }) => (
        <Checkbox
          checked={
            table.getIsAllPageRowsSelected()
              ? true
              : table.getIsSomePageRowsSelected()
                ? 'indeterminate'
                : false
          }
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
          aria-label={t('common.selectAll')}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(!!value)}
          aria-label={t('common.selectRow')}
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: 'code',
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
          >
            {t('admin.suppliers.code')}
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
    },
    {
      accessorKey: 'name',
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
          >
            {t('common.name')}
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
    },
    {
      accessorKey: 'province.name_th',
      header: t('admin.suppliers.province'),
      cell: ({ row }) => {
        const province = row.original.province;
        return <span>{province?.name_th || '-'}</span>;
      },
    },
    {
      accessorKey: 'phone',
      header: t('admin.suppliers.phone'),
      cell: ({ row }) => {
        const phone = row.getValue('phone') as string;
        if (!phone) return '-';
        // Format as xxx-xxx-xxxx
        return <span>{phone.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3')}</span>;
      },
    },
    {
      accessorKey: 'rubberTypeCodes',
      header: t('admin.analytics.rubberTypes'),
      cell: ({ row }) => {
        const details = row.original.rubberTypeDetails;

        if (!details || details.length === 0) {
          return <span className="text-muted-foreground text-xs">-</span>;
        }

        // Group by category
        const grouped = details.reduce(
          (acc, item) => {
            const category = item.category || 'Other';
            if (!acc[category]) acc[category] = [];
            acc[category].push(item);
            return acc;
          },
          {} as Record<string, typeof details>
        );

        const getCategoryColor = (category: string) => {
          const cat = category.toUpperCase();
          if (cat.includes('EUDR')) return 'bg-blue-100 text-blue-800 border-blue-200';
          if (cat.includes('FSC')) return 'bg-orange-100 text-orange-800 border-orange-200';
          if (cat.includes('REGULAR')) return 'bg-slate-100 text-slate-800 border-slate-200';
          if (cat.includes('NORTH')) return 'bg-emerald-100 text-emerald-800 border-emerald-200';
          return 'bg-secondary text-secondary-foreground';
        };

        return (
          <div className="flex flex-col gap-2">
            {Object.entries(grouped).map(([category, items]) => (
              <div key={category} className="flex flex-col gap-1">
                <span className="text-[10px] text-muted-foreground font-bold uppercase tracking-wider pl-1">
                  {category}
                </span>
                <div className="flex flex-wrap gap-1.5">
                  {items.map((item) => {
                    // Remove category prefix from name if present (case insensitive)
                    const prefix = category + ' ';
                    const displayName = item.name.toLowerCase().startsWith(prefix.toLowerCase())
                      ? item.name.slice(prefix.length)
                      : item.name;

                    return (
                      <span
                        key={item.code}
                        className={`px-2 py-0.5 rounded-md text-xs font-medium border ${getCategoryColor(
                          category
                        )}`}
                        title={item.code}
                      >
                        {displayName}
                      </span>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        );
      },
    },
    {
      accessorKey: 'status',
      header: t('common.status'),
      cell: ({ row }) => (
        <span
          className={`px-2 py-1 rounded-full text-xs font-semibold ${
            row.getValue('status') === 'ACTIVE'
              ? 'bg-green-100 text-green-800'
              : 'bg-red-100 text-red-800'
          }`}
        >
          {t(`admin.status.${(row.getValue('status') as string).toLowerCase()}`)}
        </span>
      ),
    },
    {
      id: 'actions',
      header: t('common.actions'),
      cell: ({ row }) => {
        const supplier = row.original;

        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="h-8 w-8 p-0">
                <span className="sr-only">{t('common.openMenu')}</span>
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuLabel>{t('common.actions')}</DropdownMenuLabel>
              <DropdownMenuItem onClick={() => onEdit(supplier)}>
                <Edit2 className="mr-2 h-4 w-4" />
                {t('common.edit')}
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                onClick={() => onDelete(supplier.id)}
                className="text-red-600 focus:text-red-600"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                {t('common.delete')}
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        );
      },
    },
  ];
};
