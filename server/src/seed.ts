export interface DemoUser {
  username: string;
  password: string;
  name: string;
  email: string;
  role: 'admin' | 'student';
  groupName: string | null;
  controlNumber: string | null;
  semester: number | null;
  label: string;
}

export const DEMO_USERS: DemoUser[] = [
  {
    username: 'admin',
    password: 'admin123',
    name: 'Coordinación Académica',
    email: 'coordinacion@itsuruapan.edu.mx',
    role: 'admin',
    groupName: null,
    controlNumber: null,
    semester: null,
    label: 'Administración',
  },
  {
    username: 'student1',
    password: '1234',
    name: 'Karol Rubén Quiroz Mora',
    email: 'qumk051105@itsuruapan.edu.mx',
    role: 'student',
    groupName: 'Ingeniería en Sistemas Computacionales',
    controlNumber: '23040061',
    semester: 4,
    label: 'Ingeniería en Sistemas',
  },
  {
    username: 'student2',
    password: '1234',
    name: 'Luis Ramírez Ortega',
    email: 'luro080905@itsuruapan.edu.mx',
    role: 'student',
    groupName: 'Ingeniería Mecánica',
    controlNumber: '23040062',
    semester: 4,
    label: 'Ingeniería Mecánica',
  },
];

export const DEMO_ACCOUNTS = DEMO_USERS.map((user) => ({
  username: user.username,
  password: user.password,
  name: user.name,
  role: user.role,
  group: user.groupName,
  label: user.label,
}));
