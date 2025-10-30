import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { InfoIcon, Users } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { Navigate } from "react-router-dom";

export default function UserManagement() {
  const { user } = useAuth();

  if (user?.role !== 'admin') {
    return <Navigate to="/dashboard" replace />;
  }

  return (
    <div className="p-4 md:p-8 bg-gradient-to-br from-slate-50 to-blue-50 min-h-screen">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8 flex items-center gap-3">
          <Users className="w-8 h-8 text-primary" />
          <div>
            <h1 className="text-3xl font-bold text-slate-900 mb-2">Gerenciamento de Usuários</h1>
            <p className="text-slate-600">Sistema de autenticação e controle de acesso</p>
          </div>
        </div>

        <Alert className="mb-6">
          <InfoIcon className="h-4 w-4" />
          <AlertDescription>
            <div className="space-y-4">
              <p className="font-semibold">Sistema de Autenticação Atualizado</p>
              <p>
                O sistema agora usa autenticação segura via Lovable Cloud. Os usuários são gerenciados 
                diretamente pelo sistema de autenticação e suas funções são armazenadas no banco de dados.
              </p>
              <div className="mt-4 space-y-2">
                <p className="font-medium">Como funciona o novo sistema:</p>
                <ol className="list-decimal list-inside space-y-1 text-sm">
                  <li>Novos usuários se cadastram na tela de login usando email e senha</li>
                  <li>Administradores podem atribuir funções via backend</li>
                  <li>Todas as senhas são criptografadas automaticamente</li>
                  <li>As permissões são validadas no servidor, não no cliente</li>
                </ol>
              </div>
            </div>
          </AlertDescription>
        </Alert>

        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Benefícios de Segurança</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <h3 className="font-semibold mb-2">O novo sistema oferece:</h3>
              <ul className="list-disc list-inside space-y-1 text-sm text-slate-600">
                <li>🔒 Senhas criptografadas e nunca armazenadas em texto plano</li>
                <li>🎫 Sessões seguras com tokens JWT</li>
                <li>🛡️ Validação server-side de permissões (não pode ser burlada)</li>
                <li>🚫 Proteção contra ataques de escalação de privilégios</li>
                <li>✅ Conformidade com LGPD e boas práticas de segurança</li>
                <li>🔑 Recuperação de senha por email</li>
              </ul>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Gerenciar Funções de Usuários</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-slate-600 mb-4">
              Para atribuir a função de administrador a um usuário, você precisa adicionar um registro 
              na tabela <code className="bg-slate-100 px-2 py-1 rounded">user_roles</code> no backend.
            </p>
            <div className="bg-slate-50 p-4 rounded-lg border">
              <p className="font-mono text-sm">
                INSERT INTO user_roles (user_id, role)<br />
                VALUES ('user-id-aqui', 'admin');
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
