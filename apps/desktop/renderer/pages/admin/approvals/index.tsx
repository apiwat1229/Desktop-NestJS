import { format } from 'date-fns';
import { Check, Clock, User, X } from 'lucide-react';
import Head from 'next/head';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import AdminLayout from '../../../components/AdminLayout';
import { Badge } from '../../../components/ui/badge';
import { Button } from '../../../components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '../../../components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../../../components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../../components/ui/tabs';
import { Textarea } from '../../../components/ui/textarea';
import { api } from '../../../lib/api';

interface ApprovalRequest {
  id: string;
  sourceApp: string;
  actionType: string;
  entityId: string;
  reason?: string;
  changes?: any;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  requester: {
    id: string;
    username: string;
    email: string;
    firstName?: string;
    lastName?: string;
  };
  submittedAt: string;
  approver?: {
    username: string;
  };
  comment?: string;
}

export default function ApprovalCenterPage() {
  const { t } = useTranslation();
  const [requests, setRequests] = useState<ApprovalRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedRequest, setSelectedRequest] = useState<ApprovalRequest | null>(null);
  const [actionComment, setActionComment] = useState('');
  const [actionType, setActionType] = useState<'approve' | 'reject' | null>(null);

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    try {
      setLoading(true);
      const res = await api.get('/approvals');
      setRequests(res.data);
    } catch (error) {
      console.error(error);
      toast.error(t('common.errorLoading', 'Failed to load requests'));
    } finally {
      setLoading(false);
    }
  };

  const handleAction = async () => {
    if (!selectedRequest || !actionType) return;

    try {
      await api.put(`/approvals/${selectedRequest.id}/${actionType}`, {
        comment: actionComment,
      });
      toast.success(t(`approvals.${actionType}Success`, `Request ${actionType}ed successfully`));
      fetchRequests();
      setSelectedRequest(null);
      setActionType(null);
      setActionComment('');
    } catch (error) {
      console.error(error);
      toast.error(t('common.error', 'Action failed'));
    }
  };

  const StatusBadge = ({ status }: { status: string }) => {
    const styles = {
      PENDING: 'bg-yellow-100 text-yellow-800 border-yellow-200',
      APPROVED: 'bg-green-100 text-green-800 border-green-200',
      REJECTED: 'bg-red-100 text-red-800 border-red-200',
    };
    const icons = {
      PENDING: <Clock className="w-3 h-3 mr-1" />,
      APPROVED: <Check className="w-3 h-3 mr-1" />,
      REJECTED: <X className="w-3 h-3 mr-1" />,
    };
    return (
      <Badge variant="outline" className={`flex items-center ${styles[status] || ''}`}>
        {icons[status] || null}
        {status}
      </Badge>
    );
  };

  return (
    <AdminLayout>
      <Head>
        <title>{t('admin.approvals.title', 'Approval Center')} | Admin</title>
      </Head>

      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">
              {t('admin.approvals.title', 'Approval Center')}
            </h1>
            <p className="text-sm text-muted-foreground">
              {t('admin.approvals.subtitle', 'Manage pending requests and workflows.')}
            </p>
          </div>
        </div>

        <Tabs defaultValue="pending" className="w-full">
          <TabsList>
            <TabsTrigger value="pending">
              Pending ({requests.filter((r) => r.status === 'PENDING').length})
            </TabsTrigger>
            <TabsTrigger value="history">History</TabsTrigger>
          </TabsList>

          <TabsContent value="pending" className="mt-4 space-y-4">
            {requests.filter((r) => r.status === 'PENDING').length === 0 ? (
              <div className="text-center py-10 text-muted-foreground">No pending requests.</div>
            ) : (
              <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                {requests
                  .filter((r) => r.status === 'PENDING')
                  .map((request) => (
                    <RequestCard
                      key={request.id}
                      request={request}
                      onApprove={() => {
                        setSelectedRequest(request);
                        setActionType('approve');
                      }}
                      onReject={() => {
                        setSelectedRequest(request);
                        setActionType('reject');
                      }}
                    />
                  ))}
              </div>
            )}
          </TabsContent>

          <TabsContent value="history" className="mt-4">
            <div className="border rounded-md">
              {/* Simple Table for History */}
              <table className="w-full text-sm text-left">
                <thead className="bg-muted/50 border-b">
                  <tr>
                    <th className="p-4 font-medium">Date</th>
                    <th className="p-4 font-medium">Type</th>
                    <th className="p-4 font-medium">Requester</th>
                    <th className="p-4 font-medium">Status</th>
                    <th className="p-4 font-medium">Approver</th>
                  </tr>
                </thead>
                <tbody>
                  {requests
                    .filter((r) => r.status !== 'PENDING')
                    .map((req) => (
                      <tr key={req.id} className="border-b last:border-0 hover:bg-muted/20">
                        <td className="p-4">
                          {format(new Date(req.submittedAt), 'dd MMM yyyy HH:mm')}
                        </td>
                        <td className="p-4">
                          <div className="font-medium">{req.actionType}</div>
                          <div className="text-xs text-muted-foreground">{req.sourceApp}</div>
                        </td>
                        <td className="p-4">{req.requester.username}</td>
                        <td className="p-4">
                          <StatusBadge status={req.status} />
                        </td>
                        <td className="p-4">{req.approver?.username || '-'}</td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          </TabsContent>
        </Tabs>

        {/* Action Dialog */}
        <Dialog open={!!selectedRequest} onOpenChange={(open) => !open && setSelectedRequest(null)}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {actionType === 'approve' ? 'Approve Request' : 'Reject Request'}
              </DialogTitle>
              <DialogDescription>
                {actionType === 'approve'
                  ? 'Are you sure you want to approve this request? This action will apply the changes.'
                  : 'Are you sure you want to reject this request? Please provide a reason.'}
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-4 py-4">
              {selectedRequest && (
                <div className="bg-muted p-3 rounded-md text-sm space-y-2">
                  <div className="flex justify-between">
                    <span className="font-medium">Type:</span>
                    <span>
                      {selectedRequest.sourceApp} - {selectedRequest.actionType}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-medium">Requester:</span>
                    <span>{selectedRequest.requester.username}</span>
                  </div>
                  {selectedRequest.reason && (
                    <div className="border-t pt-2 mt-2">
                      <span className="font-medium block mb-1">Reason:</span>
                      <p className="text-muted-foreground">{selectedRequest.reason}</p>
                    </div>
                  )}
                </div>
              )}

              <Textarea
                placeholder={
                  actionType === 'reject'
                    ? 'Reason for rejection (required)...'
                    : 'Optional comments...'
                }
                value={actionComment}
                onChange={(e) => setActionComment(e.target.value)}
              />
            </div>

            <DialogFooter>
              <Button variant="outline" onClick={() => setSelectedRequest(null)}>
                Cancel
              </Button>
              <Button
                variant={actionType === 'reject' ? 'destructive' : 'default'}
                onClick={handleAction}
              >
                {actionType === 'approve' ? 'Approve' : 'Reject'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  );
}

function RequestCard({
  request,
  onApprove,
  onReject,
}: {
  request: ApprovalRequest;
  onApprove: () => void;
  onReject: () => void;
}) {
  return (
    <Card>
      <CardHeader className="pb-3">
        <div className="flex justify-between items-start">
          <div>
            <Badge variant="secondary" className="mb-2">
              {request.sourceApp}
            </Badge>
            <CardTitle className="text-base">{request.actionType}</CardTitle>
          </div>
          <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">
            PENDING
          </Badge>
        </div>
        <CardDescription className="flex items-center gap-1">
          <User className="w-3 h-3" />
          {request.requester.username} • {format(new Date(request.submittedAt), 'dd MMM HH:mm')}
        </CardDescription>
      </CardHeader>
      <CardContent className="pb-3 text-sm">
        <div className="space-y-2">
          {request.reason ? (
            <p className="bg-muted p-2 rounded italic text-muted-foreground">"{request.reason}"</p>
          ) : (
            <p className="text-muted-foreground italic">No reason provided.</p>
          )}

          {/* Show changeset summary if available */}
          {request.changes && Object.keys(request.changes).length > 0 && (
            <div className="text-xs space-y-1 mt-2">
              <span className="font-medium text-foreground">Changes:</span>
              {Object.entries(request.changes).map(([key, val]: [string, any]) => (
                <div
                  key={key}
                  className="flex justify-between border-b pb-1 last:border-0 border-border/50"
                >
                  <span className="text-muted-foreground">{key}</span>
                  <span className="font-mono">{String(val)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </CardContent>
      <CardFooter className="flex justify-end gap-2 pt-0">
        <Button
          variant="outline"
          size="sm"
          className="text-red-600 hover:text-red-700 hover:bg-red-50"
          onClick={onReject}
        >
          Reject
        </Button>
        <Button size="sm" className="bg-green-600 hover:bg-green-700" onClick={onApprove}>
          Approve
        </Button>
      </CardFooter>
    </Card>
  );
}
