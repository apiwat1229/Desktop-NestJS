<script setup lang="ts" generic="TData, TValue">
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  type ColumnDef,
  FlexRender,
  type RowSelectionState,
  type SortingState,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useVueTable,
} from '@tanstack/vue-table';
import { Trash2 } from 'lucide-vue-next';
import { h, ref } from 'vue';

const props = defineProps<{
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
  searchKey?: string;
  enableSelection?: boolean;
}>();

const emit = defineEmits<{
  deleteSelected: [selectedRows: TData[]];
}>();

const sorting = ref<SortingState>([]);
const rowSelection = ref<RowSelectionState>({});

// Add select all column if selection is enabled
const columnsWithSelection = props.enableSelection
  ? [
      {
        id: 'select',
        header: ({ table }: any) =>
          h(Checkbox, {
            checked: table.getIsAllPageRowsSelected(),
            'onUpdate:checked': (value: boolean) => table.toggleAllPageRowsSelected(!!value),
            ariaLabel: 'Select all',
          }),
        cell: ({ row }: any) =>
          h(Checkbox, {
            checked: row.getIsSelected(),
            'onUpdate:checked': (value: boolean) => row.toggleSelected(!!value),
            ariaLabel: 'Select row',
          }),
        enableSorting: false,
        enableHiding: false,
      },
      ...props.columns,
    ]
  : props.columns;

const table = useVueTable({
  get data() {
    return props.data;
  },
  get columns() {
    return columnsWithSelection as any;
  },
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
  getSortedRowModel: getSortedRowModel(),
  state: {
    get sorting() {
      return sorting.value;
    },
    get rowSelection() {
      return rowSelection.value;
    },
  },
  onSortingChange: (updaterOrValue) => {
    sorting.value =
      typeof updaterOrValue === 'function' ? updaterOrValue(sorting.value) : updaterOrValue;
  },
  onRowSelectionChange: (updaterOrValue) => {
    rowSelection.value =
      typeof updaterOrValue === 'function' ? updaterOrValue(rowSelection.value) : updaterOrValue;
  },
  enableRowSelection: props.enableSelection,
});
</script>

<template>
  <div class="space-y-4 relative">
    <!-- Table -->
    <div class="relative rounded-[6px] border overflow-hidden">
      <Table class="w-full">
        <TableHeader>
          <TableRow v-for="headerGroup in table.getHeaderGroups()" :key="headerGroup.id">
            <TableHead v-for="header in headerGroup.headers" :key="header.id">
              <FlexRender
                v-if="!header.isPlaceholder"
                :render="header.column.columnDef.header"
                :props="header.getContext()"
              />
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="table.getRowModel().rows?.length">
            <TableRow
              v-for="row in table.getRowModel().rows"
              :key="row.id"
              :data-state="row.getIsSelected() ? 'selected' : undefined"
            >
              <TableCell v-for="cell in row.getVisibleCells()" :key="cell.id">
                <FlexRender :render="cell.column.columnDef.cell" :props="cell.getContext()" />
              </TableCell>
            </TableRow>
          </template>
          <template v-else>
            <TableRow>
              <TableCell :colspan="columnsWithSelection.length" class="h-24 text-center">
                No results.
              </TableCell>
            </TableRow>
          </template>
        </TableBody>
      </Table>
    </div>

    <!-- Pagination -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-4">
        <!-- Page Size Selector - Moved to front -->
        <div class="flex items-center gap-2">
          <span class="text-sm text-muted-foreground">Rows per page:</span>
          <Select
            :model-value="String(table.getState().pagination.pageSize)"
            @update:model-value="(value) => table.setPageSize(Number(value))"
          >
            <SelectTrigger class="w-[70px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="10">10</SelectItem>
              <SelectItem value="20">20</SelectItem>
              <SelectItem value="30">30</SelectItem>
              <SelectItem value="50">50</SelectItem>
              <SelectItem value="100">100</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="text-sm text-muted-foreground">
          {{ table.getFilteredSelectedRowModel().rows.length }} of
          {{ table.getFilteredRowModel().rows.length }} row(s) selected.
        </div>

        <!-- Delete Selected Button - Improved styling -->
        <Button
          v-if="table.getFilteredSelectedRowModel().rows.length > 0"
          variant="destructive"
          size="default"
          class="gap-2 font-medium shadow-md hover:shadow-lg transition-all"
          @click="
            emit(
              'deleteSelected',
              table.getFilteredSelectedRowModel().rows.map((r) => r.original)
            )
          "
        >
          <Trash2 class="w-4 h-4" />
          <span>Delete Selected ({{ table.getFilteredSelectedRowModel().rows.length }})</span>
        </Button>
      </div>

      <div class="flex items-center gap-2">
        <div class="text-sm text-muted-foreground">
          Page {{ table.getState().pagination.pageIndex + 1 }} of {{ table.getPageCount() }}
        </div>
        <div class="space-x-2">
          <Button
            variant="outline"
            size="sm"
            :disabled="!table.getCanPreviousPage()"
            @click="table.previousPage()"
          >
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            :disabled="!table.getCanNextPage()"
            @click="table.nextPage()"
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>
